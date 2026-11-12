USE libman;

-- Demo reader accounts for the XAMPP LibMan web app.
-- Shared demo password: 123
-- Hash generated with PHP password_hash(..., PASSWORD_DEFAULT).
INSERT INTO app_user
    (username, password_hash, full_name, dob, address, email, phone, role, active)
VALUES
    ('reader01', '$2y$10$akj5JMMLtXg8bdDVXxrvr.2uxOZy97GGF3FAXZ5RWNPvMWPDlJa0i', 'Bùi Công Danh', '2005-01-30', 'Hà Nội', 'danhac123@gmail.com', '0901000001', 'READER', TRUE),
    ('reader02', '$2y$10$akj5JMMLtXg8bdDVXxrvr.2uxOZy97GGF3FAXZ5RWNPvMWPDlJa0i', 'Nguyễn Minh Anh', '2004-04-12', 'Hà Nội', 'minhanh.reader@example.com', '0901000002', 'READER', TRUE),
    ('reader03', '$2y$10$akj5JMMLtXg8bdDVXxrvr.2uxOZy97GGF3FAXZ5RWNPvMWPDlJa0i', 'Trần Gia Huy', '2003-09-08', 'Đà Nẵng', 'giahuy.reader@example.com', '0901000003', 'READER', TRUE),
    ('reader04', '$2y$10$akj5JMMLtXg8bdDVXxrvr.2uxOZy97GGF3FAXZ5RWNPvMWPDlJa0i', 'Phạm Ngọc Hà', '2005-06-21', 'Hồ Chí Minh', 'ngocha.reader@example.com', '0901000004', 'READER', TRUE),
    ('reader05', '$2y$10$akj5JMMLtXg8bdDVXxrvr.2uxOZy97GGF3FAXZ5RWNPvMWPDlJa0i', 'Lê Quang Minh', '2004-12-02', 'Cần Thơ', 'quangminh.reader@example.com', '0901000005', 'READER', TRUE)
ON DUPLICATE KEY UPDATE
    password_hash = VALUES(password_hash),
    full_name = VALUES(full_name),
    dob = VALUES(dob),
    address = VALUES(address),
    email = VALUES(email),
    phone = VALUES(phone),
    role = VALUES(role),
    active = TRUE;