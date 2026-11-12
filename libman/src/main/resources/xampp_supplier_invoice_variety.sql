-- Adds two additional invoices per supplier with variable detail counts.
-- Run after xampp_supplier_statistics_extra20.sql. Safe to rerun.
USE libman;

CREATE TEMPORARY TABLE seed_supplier_invoice_variety (
  supplier_no INT PRIMARY KEY,
  supplier_name VARCHAR(180) NOT NULL
);
INSERT INTO seed_supplier_invoice_variety(supplier_no,supplier_name) VALUES
  (1,'NXB Giáo Dục Việt Nam'),
  (2,'Công ty Sách Nhã Nam'),
  (3,'Công ty Fahasa'),
  (4,'NXB Trẻ'),
  (5,'NXB Đại học Quốc gia Hà Nội'),
  (6,'NXB Bách Khoa Hà Nội'),
  (7,'Công ty Sách Alpha'),
  (8,'NXB Kim Đồng'),
  (9,'NXB Khoa học và Kỹ thuật'),
  (10,'Công ty Sách Thái Hà'),
  (11,'NXB Tài chính'),
  (12,'NXB Lao động'),
  (13,'NXB Văn hóa - Văn nghệ'),
  (14,'Công ty Sách Minh Long'),
  (15,'NXB Giao thông Vận tải'),
  (16,'NXB Phụ nữ Việt Nam'),
  (17,'Công ty Sách Đông A'),
  (18,'NXB Chính trị Quốc gia Sự thật'),
  (19,'Công ty Sách Trí Việt'),
  (20,'NXB Thế Giới');

CREATE TEMPORARY TABLE seed_invoice_variety (
  seed_note VARCHAR(100) PRIMARY KEY,
  supplier_no INT NOT NULL,
  supplier_name VARCHAR(180) NOT NULL,
  librarian_username VARCHAR(80) NOT NULL,
  import_date DATE NOT NULL,
  invoice_quantity INT NOT NULL,
  invoice_seq INT NOT NULL
);
INSERT INTO seed_invoice_variety
SELECT CONCAT('SEED-NOV2026-NCC',LPAD(s.supplier_no,3,'0'),'-',LPAD(q.invoice_seq,2,'0')),
       s.supplier_no,s.supplier_name,
       IF(MOD(s.supplier_no+q.invoice_seq,2)=0,
          'seed_stats_librarian_01','seed_stats_librarian_02'),
       IF(q.invoice_seq=2,
          DATE_ADD('2026-11-02',INTERVAL MOD(s.supplier_no-1,8) DAY),
          DATE_ADD('2026-11-03',INTERVAL MOD(s.supplier_no-1,9) DAY)),
       15+MOD(s.supplier_no*7+q.invoice_seq*5,36),
       q.invoice_seq
FROM seed_supplier_invoice_variety s
CROSS JOIN (SELECT 2 AS invoice_seq UNION ALL SELECT 3 AS invoice_seq) q;

INSERT INTO import_invoice(supplier_id,librarian_id,imported_at,note)
SELECT supplier.supplier_id,user.user_id,TIMESTAMP(seed.import_date,'10:00:00'),seed.seed_note
FROM seed_invoice_variety seed
JOIN supplier ON supplier.name=seed.supplier_name
JOIN app_user user ON user.username=seed.librarian_username
WHERE NOT EXISTS (
  SELECT 1 FROM import_invoice existing WHERE existing.note=seed.seed_note
);

UPDATE import_invoice invoice
JOIN seed_invoice_variety seed ON seed.seed_note=invoice.note
SET invoice.imported_at=TIMESTAMP(seed.import_date,'10:00:00');

-- Rebuild only these seed invoices' detail rows to make this script repeatable.
DELETE detail FROM import_detail detail
JOIN import_invoice invoice ON invoice.invoice_id=detail.invoice_id
WHERE invoice.note REGEXP '^SEED-NOV2026-NCC[0-9]{3}-(02|03)$';

-- Invoice 02: one detail line.
INSERT INTO import_detail(invoice_id,document_id,quantity,unit_price)
SELECT invoice.invoice_id,document.document_id,seed.invoice_quantity,
       72000+seed.supplier_no*975
FROM seed_invoice_variety seed
JOIN import_invoice invoice ON invoice.note=seed.seed_note
JOIN document ON document.title=ELT(MOD(seed.supplier_no-1,15)+1,
  'Phân tích thiết kế hệ thống','Cơ sở dữ liệu','Lập trình Java','Cấu trúc dữ liệu','Mạng máy tính',
  'Hệ điều hành','Trí tuệ nhân tạo','An toàn thông tin','Công nghệ phần mềm','Phát triển web',
  'Toán rời rạc','Xác suất thống kê','Kỹ năng nghiên cứu','Kinh tế học đại cương','Tiếng Anh chuyên ngành')
WHERE seed.invoice_seq=2;

-- Invoice 03: three different detail lines.
INSERT INTO import_detail(invoice_id,document_id,quantity,unit_price)
SELECT invoice.invoice_id,document.document_id,FLOOR(seed.invoice_quantity/3),
       68000+seed.supplier_no*850
FROM seed_invoice_variety seed
JOIN import_invoice invoice ON invoice.note=seed.seed_note
JOIN document ON document.title=ELT(MOD(seed.supplier_no-1,15)+1,
  'Phân tích thiết kế hệ thống','Cơ sở dữ liệu','Lập trình Java','Cấu trúc dữ liệu','Mạng máy tính',
  'Hệ điều hành','Trí tuệ nhân tạo','An toàn thông tin','Công nghệ phần mềm','Phát triển web',
  'Toán rời rạc','Xác suất thống kê','Kỹ năng nghiên cứu','Kinh tế học đại cương','Tiếng Anh chuyên ngành')
WHERE seed.invoice_seq=3
UNION ALL
SELECT invoice.invoice_id,document.document_id,FLOOR(seed.invoice_quantity/3),
       74000+seed.supplier_no*925
FROM seed_invoice_variety seed
JOIN import_invoice invoice ON invoice.note=seed.seed_note
JOIN document ON document.title=ELT(MOD(seed.supplier_no+4,15)+1,
  'Phân tích thiết kế hệ thống','Cơ sở dữ liệu','Lập trình Java','Cấu trúc dữ liệu','Mạng máy tính',
  'Hệ điều hành','Trí tuệ nhân tạo','An toàn thông tin','Công nghệ phần mềm','Phát triển web',
  'Toán rời rạc','Xác suất thống kê','Kỹ năng nghiên cứu','Kinh tế học đại cương','Tiếng Anh chuyên ngành')
WHERE seed.invoice_seq=3
UNION ALL
SELECT invoice.invoice_id,document.document_id,seed.invoice_quantity-2*FLOOR(seed.invoice_quantity/3),
       81000+seed.supplier_no*1050
FROM seed_invoice_variety seed
JOIN import_invoice invoice ON invoice.note=seed.seed_note
JOIN document ON document.title=ELT(MOD(seed.supplier_no+9,15)+1,
  'Phân tích thiết kế hệ thống','Cơ sở dữ liệu','Lập trình Java','Cấu trúc dữ liệu','Mạng máy tính',
  'Hệ điều hành','Trí tuệ nhân tạo','An toàn thông tin','Công nghệ phần mềm','Phát triển web',
  'Toán rời rạc','Xác suất thống kê','Kỹ năng nghiên cứu','Kinh tế học đại cương','Tiếng Anh chuyên ngành')
WHERE seed.invoice_seq=3;

DROP TEMPORARY TABLE seed_invoice_variety;
DROP TEMPORARY TABLE seed_supplier_invoice_variety;

-- Expected: 40 invoices, 80 detail lines; each supplier has 2 new invoices,
-- one with 1 detail and one with 3 details.
SELECT COUNT(*) AS invoice_count,
       SUM(detail_count=1) AS invoices_with_one_detail,
       SUM(detail_count=3) AS invoices_with_three_details,
       SUM(detail_count) AS detail_line_count
FROM (
  SELECT invoice.invoice_id,COUNT(detail.detail_id) AS detail_count
  FROM import_invoice invoice
  LEFT JOIN import_detail detail ON detail.invoice_id=invoice.invoice_id
  WHERE invoice.note REGEXP '^SEED-NOV2026-NCC[0-9]{3}-(02|03)$'
  GROUP BY invoice.invoice_id
) invoice_details;
