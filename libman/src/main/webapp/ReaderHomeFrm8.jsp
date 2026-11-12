<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="vn.libman.util.Html8" %>
<% Long readerId=(Long)session.getAttribute("readerId");
if(readerId==null){response.sendRedirect("dangnhap.jsp?err=timeout");
return;
} %>
<!DOCTYPE html>
<html lang="vi">
  <head><meta charset="UTF-8"><title>Reader Home - LibMan</title><%@ include file="libman-style.jspf" %>
  </head>
  <body>
    <main class="shell">
      <header class="top">
        <h1>Trang chủ bạn đọc</h1><a class="btn red" href="Logout8.jsp">Đăng xuất</a>
        </header>
        <section class="card">
          <h2>Xin chào, <%=Html8.escape(session.getAttribute("fullName"))%>
          </h2>
          <p class="muted">Chọn chức năng bạn muốn sử dụng.</p>
            <div class="toolbar"><a class="btn" href="RegisterReaderCardFrm8.jsp">Đăng ký thẻ bạn đọc</a>
            </div>
          </section>
        </main>
      </body>
    </html>
