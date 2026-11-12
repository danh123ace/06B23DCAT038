<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,vn.libman.dao.*,vn.libman.util.Html8" %>
<% Long managerId=(Long)session.getAttribute("managerId");
if(managerId==null){response.sendRedirect("dangnhap.jsp?err=timeout");
return;
}
try(Connection c=DAO8.openConnection()){if(!new ManagerDAO8(c).isActiveManager(managerId)){session.invalidate();
response.sendRedirect("dangnhap.jsp?err=role");
return;
}}catch(Exception e){application.log("Validate manager session",e);
response.sendError(503,"Không kết nối được cơ sở dữ liệu");
return;
} %>
<!DOCTYPE html>
<html lang="vi">
  <head><meta charset="UTF-8"><title>Manager Home - LibMan</title><%@ include file="libman-style.jspf" %>
  </head>
  <body>
    <main class="shell">
      <header class="top">
        <h1>Trang chủ quản lý thư viện</h1><a class="btn red" href="Logout8.jsp">Đăng xuất</a>
        </header>
        <section class="card">
          <p>Quản lý: <b><%=Html8.escape(session.getAttribute("fullName"))%>
            </b>
          </p>
          <h3>Menu chức năng quản lý</h3>
            <div class="toolbar"><a class="btn secondary" href="SelectStatisticHomeFrm8.jsp">Xem báo cáo / Thống kê</a>
            </div>
          </section>
        </main>
      </body>
    </html>
