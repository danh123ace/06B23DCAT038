-- Run after xampp_supplier_statistics.sql against the `libman` database.
-- Idempotent additions for the JSP demonstration module.
USE libman;

CREATE TABLE IF NOT EXISTS reader (
  reader_id BIGINT NOT NULL PRIMARY KEY,
  user_id BIGINT NOT NULL UNIQUE,
  CONSTRAINT fk_reader_user FOREIGN KEY (user_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS manager (
  manager_id BIGINT NOT NULL PRIMARY KEY,
  user_id BIGINT NOT NULL UNIQUE,
  CONSTRAINT fk_manager_user FOREIGN KEY (user_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS librarian (
  librarian_id BIGINT NOT NULL PRIMARY KEY,
  user_id BIGINT NOT NULL UNIQUE,
  CONSTRAINT fk_librarian_user FOREIGN KEY (user_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS reader_card (
  card_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  reader_id BIGINT NOT NULL,
  card_code VARCHAR(40) NOT NULL UNIQUE,
  card_type VARCHAR(40) NOT NULL,
  issue_date DATE NOT NULL,
  expiry_date DATE NOT NULL,
  status ENUM('ACTIVE','EXPIRED','LOCKED') NOT NULL DEFAULT 'ACTIVE',
  block_reason VARCHAR(300) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_reader_card_current(reader_id,status,expiry_date),
  CONSTRAINT fk_reader_card_reader FOREIGN KEY(reader_id) REFERENCES reader(reader_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO reader(reader_id,user_id)
  SELECT user_id,user_id FROM app_user WHERE role='READER';
INSERT IGNORE INTO manager(manager_id,user_id)
  SELECT user_id,user_id FROM app_user WHERE role='MANAGER';
INSERT IGNORE INTO librarian(librarian_id,user_id)
  SELECT user_id,user_id FROM app_user WHERE role='LIBRARIAN';

DROP PROCEDURE IF EXISTS sp_reader_profile;
DROP PROCEDURE IF EXISTS sp_reader_update_contact;
DROP PROCEDURE IF EXISTS sp_reader_current_card;
DROP PROCEDURE IF EXISTS sp_reader_card_mark_expired;
DROP PROCEDURE IF EXISTS sp_reader_card_create;
DROP PROCEDURE IF EXISTS sp_supplier_statistic;
DROP PROCEDURE IF EXISTS sp_import_invoice_by_supplier;
DROP PROCEDURE IF EXISTS sp_import_invoice_detail;
DROP PROCEDURE IF EXISTS sp_manager_is_active;
DROP PROCEDURE IF EXISTS sp_account_by_username;
DELIMITER $$
CREATE PROCEDURE sp_reader_profile(IN p_reader_id BIGINT)
BEGIN
  SELECT r.reader_id,u.user_id,u.full_name,u.dob,u.address,u.email,u.phone
  FROM reader r JOIN app_user u ON u.user_id=r.user_id
  WHERE r.reader_id=p_reader_id AND u.active=TRUE AND u.role='READER';
END$$

CREATE PROCEDURE sp_reader_update_contact(
  IN p_reader_id BIGINT, IN p_address VARCHAR(300), IN p_email VARCHAR(160), IN p_phone VARCHAR(40))
BEGIN
  UPDATE app_user u JOIN reader r ON r.user_id=u.user_id
  SET u.address=p_address,u.email=p_email,u.phone=p_phone
  WHERE r.reader_id=p_reader_id AND u.active=TRUE AND u.role='READER';
  IF ROW_COUNT()=0 AND NOT EXISTS(SELECT 1 FROM reader WHERE reader_id=p_reader_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Không tìm thấy bạn đọc';
  END IF;
END$$

CREATE PROCEDURE sp_reader_current_card(IN p_reader_id BIGINT)
BEGIN
  SELECT card_id,reader_id,card_code,card_type,issue_date,expiry_date,status,block_reason
  FROM reader_card WHERE reader_id=p_reader_id
  ORDER BY card_id DESC LIMIT 1;
END$$

CREATE PROCEDURE sp_reader_card_mark_expired(IN p_card_id BIGINT)
BEGIN
  UPDATE reader_card SET status='EXPIRED'
  WHERE card_id=p_card_id AND status='ACTIVE' AND expiry_date<CURRENT_DATE();
END$$

CREATE PROCEDURE sp_reader_card_create(IN p_reader_id BIGINT, IN p_card_type VARCHAR(40))
BEGIN
  DECLARE v_card_id BIGINT;
  DECLARE v_lock BIGINT;
  SELECT reader_id INTO v_lock FROM reader WHERE reader_id=p_reader_id FOR UPDATE;
  IF v_lock IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Không tìm thấy bạn đọc'; END IF;
  IF EXISTS(SELECT 1 FROM reader_card WHERE reader_id=p_reader_id AND status='ACTIVE'
            AND expiry_date>=CURRENT_DATE()) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Bạn đọc đang có thẻ còn hiệu lực';
  END IF;
  UPDATE reader_card SET status='EXPIRED'
    WHERE reader_id=p_reader_id AND status='ACTIVE' AND expiry_date<CURRENT_DATE();
  INSERT INTO reader_card(reader_id,card_code,card_type,issue_date,expiry_date,status)
  VALUES(p_reader_id,CONCAT('T',UPPER(SUBSTRING(REPLACE(UUID(),'-',''),1,18)),LPAD(p_reader_id,4,'0')),
         p_card_type,CURRENT_DATE(),DATE_ADD(CURRENT_DATE(),INTERVAL 1 YEAR),'ACTIVE');
  SET v_card_id=LAST_INSERT_ID();
  SELECT card_id,reader_id,card_code,card_type,issue_date,expiry_date,status,block_reason
  FROM reader_card WHERE card_id=v_card_id;
END$$

CREATE PROCEDURE sp_supplier_statistic(IN p_start DATE, IN p_end DATE)
BEGIN
  SELECT s.supplier_id,s.name AS supplier_name,s.address,s.phone,s.email,s.description,
         COUNT(DISTINCT i.invoice_id) AS invoice_count,
         COALESCE(SUM(d.quantity),0) AS total_quantity,
         COALESCE(SUM(d.quantity*d.unit_price),0) AS total_amount
  FROM supplier s
  LEFT JOIN import_invoice i ON i.supplier_id=s.supplier_id
       AND i.imported_at>=p_start AND i.imported_at<DATE_ADD(p_end,INTERVAL 1 DAY)
  LEFT JOIN import_detail d ON d.invoice_id=i.invoice_id
  WHERE s.active=TRUE
  GROUP BY s.supplier_id,s.name,s.address,s.phone,s.email,s.description
  ORDER BY total_quantity DESC,s.name;
END$$

CREATE PROCEDURE sp_import_invoice_by_supplier(
  IN p_supplier_id BIGINT, IN p_start DATE, IN p_end DATE)
BEGIN
  SELECT i.invoice_id,i.supplier_id,i.librarian_id,
         CONCAT('HDN',DATE_FORMAT(i.imported_at,'%Y%m'),LPAD(i.invoice_id,4,'0')) AS invoice_code,
         DATE(i.imported_at) AS imported_at,i.note,
         COALESCE(SUM(d.quantity),0) AS total_quantity,
         COALESCE(SUM(d.quantity*d.unit_price),0) AS total_amount
  FROM import_invoice i LEFT JOIN import_detail d ON d.invoice_id=i.invoice_id
  WHERE i.supplier_id=p_supplier_id AND i.imported_at>=p_start
        AND i.imported_at<DATE_ADD(p_end,INTERVAL 1 DAY)
  GROUP BY i.invoice_id,i.supplier_id,i.librarian_id,i.imported_at,i.note
  ORDER BY i.imported_at DESC,i.invoice_id DESC;
END$$

CREATE PROCEDURE sp_import_invoice_detail(IN p_invoice_id BIGINT)
BEGIN
  SELECT d.detail_id,d.invoice_id,doc.document_id,doc.title,doc.publisher,
         CAST(doc.publication_year AS CHAR) AS publication_year,doc.description,
         d.quantity,d.unit_price,NULL AS note
  FROM import_detail d JOIN document doc ON doc.document_id=d.document_id
  WHERE d.invoice_id=p_invoice_id ORDER BY d.detail_id;
END$$

CREATE PROCEDURE sp_manager_is_active(IN p_manager_id BIGINT)
BEGIN
  SELECT EXISTS(SELECT 1 FROM manager m JOIN app_user u ON u.user_id=m.user_id
                WHERE m.manager_id=p_manager_id AND u.active=TRUE AND u.role='MANAGER') AS is_active;
END$$

CREATE PROCEDURE sp_account_by_username(IN p_username VARCHAR(80))
BEGIN
  SELECT u.user_id,u.username,u.full_name,u.password_hash,u.role,
         r.reader_id,m.manager_id
  FROM app_user u LEFT JOIN reader r ON r.user_id=u.user_id
       LEFT JOIN manager m ON m.user_id=u.user_id
  WHERE u.username=p_username AND u.active=TRUE LIMIT 1;
END$$
DELIMITER ;
