# LibMan - JSP Web Application

Ứng dụng web Java theo mô hình Maven WAR, dùng JSP cho các trang, model/entity cho dữ liệu, DAO gọi stored procedure và service xử lý nghiệp vụ đăng ký thẻ. Cấu trúc có thể import vào Eclipse Enterprise Java/Web:

- `src/main/java`: model, DAO, service Java.
- `src/main/resources`: schema, dữ liệu mẫu và stored procedure MariaDB.
- `src/main/webapp`: JSP, CSS, `WEB-INF/web.xml`.
- `.project`, `.classpath`, `.settings`: cấu hình Eclipse Web Application.

## Các luồng JSP

- Đăng nhập, phân vai trò: `dangnhap.jsp` → `DoLogin8.jsp`.
- Bạn đọc: `ReaderHomeFrm8.jsp` → `RegisterReaderCardFrm8.jsp` → `DoRegisterReaderCard8.jsp`.
- Quản lý: `ManagerHomeFrm8.jsp` → `SelectStatisticHomeFrm8.jsp` → `SupplierStatisticFrm8.jsp` → `ImportInvoiceListFrm8.jsp` → `ImportInvoiceDetailFrm8.jsp`.
- `Logout8.jsp` kết thúc session.

JSP xác thực vai trò qua session; các trang thống kê xác thực manager với cơ sở dữ liệu. Các DAO truy vấn bằng stored procedure qua `CallableStatement`.

## Database MariaDB trong XAMPP

Chạy các script trong database `libman` theo thứ tự:

1. `src/main/resources/xampp_supplier_statistics.sql`: tạo schema và 15 nhà cung cấp cùng dữ liệu nhập ban đầu.
2. `src/main/resources/xampp_supplier_statistics_extra20.sql`: thêm 5 nhà cung cấp và 20 hóa đơn với 40 dòng chi tiết.
3. `src/main/resources/xampp_supplier_invoice_variety.sql`: thêm hai hóa đơn cho mỗi nhà cung cấp; một hóa đơn có một dòng chi tiết, hóa đơn còn lại có ba dòng.
4. `src/main/resources/xampp_jsp_procedures.sql`: tạo các bảng vai trò, bảng thẻ bạn đọc và stored procedure mà webapp sử dụng.
5. `src/main/resources/seed_reader_accounts.sql`: thêm tài khoản bạn đọc mẫu.

Dữ liệu nhập mẫu tháng 11/2026 có 20 nhà cung cấp, 60 hóa đơn và 120 dòng chi tiết trong khoảng 01/11/2026–12/11/2026. JDBC có thể cấu hình bằng biến môi trường `LIBMAN_JDBC_URL`, `LIBMAN_DB_USER`, `LIBMAN_DB_PASSWORD`; mặc định là `jdbc:mariadb://127.0.0.1:3306/libman`, user `root`, mật khẩu rỗng.

## Đóng gói và chạy

Yêu cầu JDK 17, Maven và Apache Tomcat 8.5 trở lên. Chạy `mvn clean package`, sau đó deploy `target/libman.war` vào Tomcat và mở `http://localhost:8080/libman/`. Apache HTTPD của XAMPP phục vụ PHP/HTML tĩnh; JSP cần Tomcat.

Tài khoản demo trong dữ liệu mẫu: manager và reader01–reader05; mật khẩu mẫu là `123`.
