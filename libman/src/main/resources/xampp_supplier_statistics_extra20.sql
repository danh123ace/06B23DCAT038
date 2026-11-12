-- Adds a November 2026 report sample with 20 suppliers and 20 import invoices.
-- Run after xampp_supplier_statistics.sql. Safe to run repeatedly.
USE libman;

-- Normalize legacy supplier labels before matching the plain seed names below.
UPDATE supplier
SET name=TRIM(SUBSTRING(name,LOCATE(' - ',name)+3))
WHERE name REGEXP '^NCC[0-9]+ - ';

INSERT IGNORE INTO supplier(name,address,phone,email,description,active) VALUES
  ('NXB Phụ nữ Việt Nam','16 Hàng Chuối, Hà Nội','02439710717','contact@nxbphunu.example','Sách văn học và gia đình',TRUE),
  ('Công ty Sách Đông A','46 Nguyễn Thị Minh Khai, TP. Hồ Chí Minh','02838225223','info@donga.example','Sách mỹ thuật và văn hóa',TRUE),
  ('NXB Chính trị Quốc gia Sự thật','6/86 Duy Tân, Hà Nội','08044040','sach@stbook.vn.example','Sách chính trị và pháp luật',TRUE),
  ('Công ty Sách Trí Việt','17H Nguyễn Thị Minh Khai, TP. Hồ Chí Minh','02839104688','sales@triviet.example','Sách kỹ năng và giáo dục',TRUE),
  ('NXB Thế Giới','46 Trần Hưng Đạo, Hà Nội','02438253841','info@thegioipublishers.example','Sách ngoại văn và tham khảo',TRUE);

CREATE TEMPORARY TABLE IF NOT EXISTS seed_supplier_november (
  supplier_no INT PRIMARY KEY,
  supplier_name VARCHAR(180) NOT NULL,
  total_quantity INT NOT NULL
);
DELETE FROM seed_supplier_november;
INSERT INTO seed_supplier_november(supplier_no,supplier_name,total_quantity) VALUES
  (1,'NXB Giáo Dục Việt Nam',40),
  (2,'Công ty Sách Nhã Nam',55),
  (3,'Công ty Fahasa',35),
  (4,'NXB Trẻ',70),
  (5,'NXB Đại học Quốc gia Hà Nội',45),
  (6,'NXB Bách Khoa Hà Nội',60),
  (7,'Công ty Sách Alpha',50),
  (8,'NXB Kim Đồng',30),
  (9,'NXB Khoa học và Kỹ thuật',65),
  (10,'Công ty Sách Thái Hà',25),
  (11,'NXB Tài chính',80),
  (12,'NXB Lao động',90),
  (13,'NXB Văn hóa - Văn nghệ',38),
  (14,'Công ty Sách Minh Long',58),
  (15,'NXB Giao thông Vận tải',48),
  (16,'NXB Phụ nữ Việt Nam',75),
  (17,'Công ty Sách Đông A',42),
  (18,'NXB Chính trị Quốc gia Sự thật',68),
  (19,'Công ty Sách Trí Việt',33),
  (20,'NXB Thế Giới',88);

INSERT INTO import_invoice(supplier_id,librarian_id,imported_at,note)
SELECT s.supplier_id,u.user_id,
       TIMESTAMP(DATE_ADD('2026-11-01',INTERVAL MOD(seed.supplier_no-1,12) DAY),'10:00:00'),
       CONCAT('SEED-NOV2026-NCC',LPAD(seed.supplier_no,3,'0'))
FROM seed_supplier_november seed
JOIN supplier s ON s.name=seed.supplier_name
JOIN app_user u ON u.username=IF(MOD(seed.supplier_no,2)=1,
                                'seed_stats_librarian_01','seed_stats_librarian_02')
WHERE NOT EXISTS (
  SELECT 1 FROM import_invoice old
  WHERE old.note=CONCAT('SEED-NOV2026-NCC',LPAD(seed.supplier_no,3,'0'))
);

-- Replace seed details so each supplier has its own invoice contents and totals.
DELETE detail FROM import_detail detail
JOIN import_invoice invoice ON invoice.invoice_id=detail.invoice_id
WHERE invoice.note REGEXP '^SEED-NOV2026-NCC[0-9]+$';

INSERT INTO import_detail(invoice_id,document_id,quantity,unit_price)
SELECT invoice.invoice_id,doc.document_id,FLOOR(seed.total_quantity/2),
       75000 + seed.supplier_no*1250
FROM seed_supplier_november seed
JOIN import_invoice invoice
  ON invoice.note=CONCAT('SEED-NOV2026-NCC',LPAD(seed.supplier_no,3,'0'))
JOIN document doc ON doc.title=ELT(MOD(seed.supplier_no-1,15)+1,
  'Phân tích thiết kế hệ thống','Cơ sở dữ liệu','Lập trình Java','Cấu trúc dữ liệu','Mạng máy tính',
  'Hệ điều hành','Trí tuệ nhân tạo','An toàn thông tin','Công nghệ phần mềm','Phát triển web',
  'Toán rời rạc','Xác suất thống kê','Kỹ năng nghiên cứu','Kinh tế học đại cương','Tiếng Anh chuyên ngành')
UNION ALL
SELECT invoice.invoice_id,doc.document_id,seed.total_quantity-FLOOR(seed.total_quantity/2),
       68000 + seed.supplier_no*1100
FROM seed_supplier_november seed
JOIN import_invoice invoice
  ON invoice.note=CONCAT('SEED-NOV2026-NCC',LPAD(seed.supplier_no,3,'0'))
JOIN document doc ON doc.title=ELT(MOD(seed.supplier_no+6,15)+1,
  'Phân tích thiết kế hệ thống','Cơ sở dữ liệu','Lập trình Java','Cấu trúc dữ liệu','Mạng máy tính',
  'Hệ điều hành','Trí tuệ nhân tạo','An toàn thông tin','Công nghệ phần mềm','Phát triển web',
  'Toán rời rạc','Xác suất thống kê','Kỹ năng nghiên cứu','Kinh tế học đại cương','Tiếng Anh chuyên ngành');

DROP TEMPORARY TABLE seed_supplier_november;

-- Expected for 2026-11-01 through 2026-11-12: 20 suppliers, 20 invoices,
-- 40 invoice-detail lines, 1,095 copies.
SELECT COUNT(*) AS supplier_count,
       SUM(invoice_count) AS invoice_count,
       SUM(detail_line_count) AS detail_line_count,
       SUM(total_quantity) AS total_quantity
FROM (
  SELECT s.supplier_id,COUNT(DISTINCT i.invoice_id) AS invoice_count,
         COUNT(d.detail_id) AS detail_line_count,
         COALESCE(SUM(d.quantity),0) AS total_quantity
  FROM supplier s
  LEFT JOIN import_invoice i ON i.supplier_id=s.supplier_id
       AND i.imported_at>='2026-11-01 00:00:00' AND i.imported_at<'2026-11-13 00:00:00'
  LEFT JOIN import_detail d ON d.invoice_id=i.invoice_id
  WHERE s.active=TRUE
  GROUP BY s.supplier_id
) report_rows;
