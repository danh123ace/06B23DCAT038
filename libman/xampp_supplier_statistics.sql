-- MariaDB / XAMPP setup for LibMan supplier-import statistics.
-- Creates (or reuses) database `libman`; it does not drop or truncate tables.
-- Seed is repeatable: supplier, document, users and invoice lines are not duplicated.

CREATE DATABASE IF NOT EXISTS libman CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE libman;

CREATE TABLE IF NOT EXISTS app_user (
  user_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(80) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(160) NOT NULL,
  dob DATE NULL,
  address VARCHAR(300) NULL,
  email VARCHAR(160) NULL,
  phone VARCHAR(40) NULL,
  role ENUM('MANAGER','LIBRARIAN','READER') NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS supplier (
  supplier_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(180) NOT NULL UNIQUE,
  address VARCHAR(300) NULL,
  phone VARCHAR(40) NULL,
  email VARCHAR(160) NULL,
  description TEXT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS document (
  document_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(300) NOT NULL UNIQUE,
  publisher VARCHAR(180) NULL,
  publication_year INT NULL,
  description TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_invoice (
  invoice_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  supplier_id BIGINT NOT NULL,
  librarian_id BIGINT NOT NULL,
  imported_at DATETIME NOT NULL,
  note VARCHAR(100) NULL,
  UNIQUE KEY uq_import_invoice_seed_note (note),
  KEY ix_import_date_supplier (imported_at,supplier_id),
  CONSTRAINT fk_import_supplier FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id),
  CONSTRAINT fk_import_librarian FOREIGN KEY (librarian_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_detail (
  detail_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT NOT NULL,
  document_id BIGINT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(14,2) NOT NULL CHECK (unit_price >= 0),
  UNIQUE KEY uq_import_detail_document (invoice_id,document_id),
  CONSTRAINT fk_detail_invoice FOREIGN KEY (invoice_id) REFERENCES import_invoice(invoice_id),
  CONSTRAINT fk_detail_document FOREIGN KEY (document_id) REFERENCES document(document_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Keep the supplier code separate from the supplier name shown by the JSP.
UPDATE supplier
SET name=TRIM(SUBSTRING(name,LOCATE(' - ',name)+3))
WHERE name REGEXP '^NCC[0-9]+ - ';

INSERT INTO app_user(username,password_hash,full_name,role,active) VALUES
  ('manager','demo-only-not-a-password-hash','Quản lý Demo Thống kê','MANAGER',TRUE),
  ('seed_stats_librarian_01','demo-only-not-a-password-hash','Nguyễn Thị Mai','LIBRARIAN',TRUE),
  ('seed_stats_librarian_02','demo-only-not-a-password-hash','Trần Văn Nam','LIBRARIAN',TRUE)
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name),role=VALUES(role),active=TRUE;

INSERT IGNORE INTO supplier(name,address,phone,email,description,active) VALUES
  ('NXB Giáo Dục Việt Nam','81 Trần Hưng Đạo, Hà Nội','0243822080','contact@nxb-giaoduc.example','Sách giáo khoa và giáo trình',TRUE),
  ('Công ty Sách Nhã Nam','59 Đỗ Quang, Hà Nội','0243514687','lienhe@nhanam.example','Sách văn học và kỹ năng',TRUE),
  ('Công ty Fahasa','60-62 Lê Lợi, TP. Hồ Chí Minh','0283822579','online@fahasa.example','Sách tổng hợp',TRUE),
  ('NXB Trẻ','161B Lý Chính Thắng, TP. Hồ Chí Minh','02839316289','info@nxbtre.example','Sách chuyên ngành và thiếu nhi',TRUE),
  ('NXB Đại học Quốc gia Hà Nội','16 Hàng Chuối, Hà Nội','02439714896','contact@press.vnu.example','Giáo trình đại học',TRUE),
  ('NXB Bách Khoa Hà Nội','Số 1 Đại Cồ Việt, Hà Nội','02438692008','press@hust.example','Tài liệu kỹ thuật',TRUE),
  ('Công ty Sách Alpha','Tầng 2, 176 Thái Hà, Hà Nội','02437227286','info@alphabooks.example','Sách kinh tế và quản trị',TRUE),
  ('NXB Kim Đồng','55 Quang Trung, Hà Nội','02439434730','info@nxbkimdong.example','Sách thiếu nhi',TRUE),
  ('NXB Khoa học và Kỹ thuật','70 Trần Hưng Đạo, Hà Nội','02438220686','nxbkhkt@example','Sách khoa học kỹ thuật',TRUE),
  ('Công ty Sách Thái Hà','119C5 Tô Hiệu, Hà Nội','02437930936','contact@thaihabooks.example','Sách kỹ năng và công nghệ',TRUE),
  ('NXB Tài chính','Hà Nội','02438240650','info@fina.example','Sách kinh tế tài chính',TRUE),
  ('NXB Lao động','175 Giảng Võ, Hà Nội','02438515380','contact@laodong.example','Sách pháp luật và xã hội',TRUE),
  ('NXB Văn hóa - Văn nghệ','TP. Hồ Chí Minh','02839304962','info@vhvn.example','Sách văn hóa nghệ thuật',TRUE),
  ('Công ty Sách Minh Long','TP. Hồ Chí Minh','02838563379','sales@minhlong.example','Sách tham khảo',TRUE),
  ('NXB Giao thông Vận tải','80B Trần Hưng Đạo, Hà Nội','02439423346','contact@gtvt.example','Sách giao thông và xây dựng',TRUE);

INSERT IGNORE INTO document(title,publisher,publication_year,description) VALUES
  ('Phân tích thiết kế hệ thống','LibMan Press',2024,'Giáo trình phân tích và thiết kế'),
  ('Cơ sở dữ liệu','LibMan Press',2024,'Giáo trình cơ sở dữ liệu'),
  ('Lập trình Java','LibMan Press',2024,'Giáo trình lập trình hướng đối tượng'),
  ('Cấu trúc dữ liệu','LibMan Press',2024,'Giáo trình cấu trúc dữ liệu và giải thuật'),
  ('Mạng máy tính','LibMan Press',2024,'Giáo trình mạng máy tính'),
  ('Hệ điều hành','LibMan Press',2024,'Giáo trình hệ điều hành'),
  ('Trí tuệ nhân tạo','LibMan Press',2024,'Tài liệu nhập môn trí tuệ nhân tạo'),
  ('An toàn thông tin','LibMan Press',2024,'Giáo trình an toàn thông tin'),
  ('Công nghệ phần mềm','LibMan Press',2024,'Giáo trình công nghệ phần mềm'),
  ('Phát triển web','LibMan Press',2024,'Tài liệu phát triển ứng dụng web'),
  ('Toán rời rạc','LibMan Press',2024,'Giáo trình toán rời rạc'),
  ('Xác suất thống kê','LibMan Press',2024,'Giáo trình xác suất thống kê'),
  ('Kỹ năng nghiên cứu','LibMan Press',2024,'Tài liệu phương pháp nghiên cứu'),
  ('Kinh tế học đại cương','LibMan Press',2024,'Giáo trình kinh tế học'),
  ('Tiếng Anh chuyên ngành','LibMan Press',2024,'Tài liệu tiếng Anh chuyên ngành');

-- Normalize legacy seeded document titles and keep invoice-detail references valid.
CREATE TEMPORARY TABLE document_title_map (
  old_document_id BIGINT PRIMARY KEY,
  new_document_id BIGINT NOT NULL,
  clean_title VARCHAR(300) NOT NULL
);
INSERT INTO document_title_map(old_document_id,new_document_id,clean_title)
SELECT old_doc.document_id,COALESCE(clean_doc.document_id,old_doc.document_id),
       TRIM(SUBSTRING_INDEX(old_doc.title,' - ',-1))
FROM document old_doc
LEFT JOIN document clean_doc
  ON clean_doc.title=TRIM(SUBSTRING_INDEX(old_doc.title,' - ',-1))
WHERE old_doc.title REGEXP '^Tài liệu mẫu [0-9]+ - ';

CREATE TEMPORARY TABLE normalized_import_details AS
SELECT detail.invoice_id,map.new_document_id AS document_id,
       SUM(detail.quantity) AS quantity,
       ROUND(SUM(detail.quantity*detail.unit_price)/NULLIF(SUM(detail.quantity),0),2) AS unit_price
FROM import_detail detail
JOIN document_title_map map
  ON detail.document_id=map.old_document_id OR detail.document_id=map.new_document_id
GROUP BY detail.invoice_id,map.new_document_id;
DELETE detail FROM import_detail detail
JOIN document_title_map map
  ON detail.document_id=map.old_document_id OR detail.document_id=map.new_document_id;
INSERT INTO import_detail(invoice_id,document_id,quantity,unit_price)
SELECT invoice_id,document_id,quantity,unit_price FROM normalized_import_details;
UPDATE document old_doc
JOIN document_title_map map ON map.old_document_id=old_doc.document_id
SET old_doc.title=map.clean_title
WHERE map.old_document_id=map.new_document_id;
DELETE old_doc FROM document old_doc
JOIN document_title_map map ON map.old_document_id=old_doc.document_id
WHERE map.old_document_id<>map.new_document_id;
DROP TEMPORARY TABLE normalized_import_details;
DROP TEMPORARY TABLE document_title_map;
CREATE TEMPORARY TABLE seed_supplier (
  supplier_no INT PRIMARY KEY,
  supplier_name VARCHAR(180) NOT NULL,
  total_quantity INT NOT NULL
);
INSERT INTO seed_supplier VALUES
  (1,'NXB Giáo Dục Việt Nam',150),
  (2,'Công ty Sách Nhã Nam',85),
  (3,'Công ty Fahasa',40),
  (4,'NXB Trẻ',75),
  (5,'NXB Đại học Quốc gia Hà Nội',120),
  (6,'NXB Bách Khoa Hà Nội',68),
  (7,'Công ty Sách Alpha',95),
  (8,'NXB Kim Đồng',50),
  (9,'NXB Khoa học và Kỹ thuật',110),
  (10,'Công ty Sách Thái Hà',32),
  (11,'NXB Tài chính',88),
  (12,'NXB Lao động',130),
  (13,'NXB Văn hóa - Văn nghệ',63),
  (14,'Công ty Sách Minh Long',105),
  (15,'NXB Giao thông Vận tải',97);

CREATE TEMPORARY TABLE seed_invoice (
  seed_note VARCHAR(100) PRIMARY KEY,
  supplier_no INT NOT NULL,
  supplier_name VARCHAR(180) NOT NULL,
  librarian_username VARCHAR(80) NOT NULL,
  import_date DATE NOT NULL,
  invoice_quantity INT NOT NULL,
  invoice_seq INT NOT NULL
);
INSERT INTO seed_invoice
SELECT CONCAT('SEED-NCC',LPAD(s.supplier_no,3,'0'),'-',n.invoice_seq),
       s.supplier_no,s.supplier_name,
       IF(n.invoice_seq=1,'seed_stats_librarian_01','seed_stats_librarian_02'),
       IF(n.invoice_seq=1,DATE_ADD('2026-09-01',INTERVAL s.supplier_no-1 DAY),
          DATE_ADD('2026-10-01',INTERVAL MOD(s.supplier_no-1,14) DAY)),
       IF(n.invoice_seq=1,FLOOR(s.total_quantity/2),s.total_quantity-FLOOR(s.total_quantity/2)),
       n.invoice_seq
FROM seed_supplier s
CROSS JOIN (SELECT 1 AS invoice_seq UNION ALL SELECT 2 AS invoice_seq) n;

INSERT INTO import_invoice(supplier_id,librarian_id,imported_at,note)
SELECT s.supplier_id,u.user_id,TIMESTAMP(i.import_date,'10:00:00'),i.seed_note
FROM seed_invoice i
JOIN supplier s ON s.name=i.supplier_name
JOIN app_user u ON u.username=i.librarian_username
WHERE NOT EXISTS (SELECT 1 FROM import_invoice old WHERE old.note=i.seed_note);

-- Each invoice has two distinct document lines; INSERT IGNORE makes reruns safe.
INSERT IGNORE INTO import_detail(invoice_id,document_id,quantity,unit_price)
SELECT i.invoice_id,d.document_id,GREATEST(1,FLOOR(s.invoice_quantity*3/5)),85000+s.supplier_no*1000
FROM seed_invoice s
JOIN import_invoice i ON i.note=s.seed_note
JOIN document d ON d.title=ELT(MOD(s.supplier_no+s.invoice_seq-2,15)+1,
    'Phân tích thiết kế hệ thống','Cơ sở dữ liệu','Lập trình Java','Cấu trúc dữ liệu','Mạng máy tính',
    'Hệ điều hành','Trí tuệ nhân tạo','An toàn thông tin','Công nghệ phần mềm','Phát triển web',
    'Toán rời rạc','Xác suất thống kê','Kỹ năng nghiên cứu','Kinh tế học đại cương','Tiếng Anh chuyên ngành')
UNION ALL
SELECT i.invoice_id,d.document_id,s.invoice_quantity-GREATEST(1,FLOOR(s.invoice_quantity*3/5)),90000+s.invoice_seq*2500
FROM seed_invoice s
JOIN import_invoice i ON i.note=s.seed_note
JOIN document d ON d.title=ELT(MOD(s.supplier_no+s.invoice_seq-1,15)+1,
    'Phân tích thiết kế hệ thống','Cơ sở dữ liệu','Lập trình Java','Cấu trúc dữ liệu','Mạng máy tính',
    'Hệ điều hành','Trí tuệ nhân tạo','An toàn thông tin','Công nghệ phần mềm','Phát triển web',
    'Toán rời rạc','Xác suất thống kê','Kỹ năng nghiên cứu','Kinh tế học đại cương','Tiếng Anh chuyên ngành');

DROP TEMPORARY TABLE seed_invoice;
DROP TEMPORARY TABLE seed_supplier;

-- Expected report totals for the default UI range (2026-09-01 through 2026-10-14):
-- NCC001 150, NCC002 85, NCC003 40; all 15 suppliers have invoices.
SELECT s.name,COUNT(DISTINCT i.invoice_id) AS invoice_count,
       COALESCE(SUM(d.quantity),0) AS total_quantity,
       COALESCE(SUM(d.quantity*d.unit_price),0) AS total_amount
FROM supplier s
LEFT JOIN import_invoice i ON i.supplier_id=s.supplier_id
     AND i.imported_at>='2026-09-01 00:00:00' AND i.imported_at<'2026-10-15 00:00:00'
LEFT JOIN import_detail d ON d.invoice_id=i.invoice_id
WHERE s.active=TRUE
GROUP BY s.supplier_id,s.name
ORDER BY (SUM(d.quantity) IS NULL),SUM(d.quantity) DESC,s.name;
