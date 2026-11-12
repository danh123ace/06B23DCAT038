<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.time.*,vn.libman.util.Html8" %>
<%
Long managerId = (Long) session.getAttribute("managerId");
if (managerId == null) {
  response.sendRedirect("dangnhap.jsp?err=timeout");
  return;
}

LocalDate today = LocalDate.now();
LocalDate defaultStart = today.withDayOfMonth(1);
String from = request.getParameter("from");
String to = request.getParameter("to");
if (from == null || !from.matches("\\d{4}-\\d{2}-\\d{2}")) {
  from = defaultStart.toString();
}
if (to == null || !to.matches("\\d{4}-\\d{2}-\\d{2}")) {
  to = today.toString();
}
boolean invalidRange = "date".equals(request.getParameter("err"));
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8">
    <title>Chọn thống kê</title>
    <%@ include file="libman-style.jspf" %>
  </head>
  <body>
    <main class="shell">
      <header class="top">
        <h1>Chọn loại báo cáo thống kê</h1>
        <a class="btn secondary" href="ManagerHomeFrm8.jsp">Trang chủ</a>
      </header>
      <section class="card">
        <form id="statisticsForm" method="get" action="SupplierStatisticFrm8.jsp">
          <div class="field">
            <label for="type">Chọn loại thống kê</label>
            <select id="type" name="type">
              <option value="supplier">Thống kê nhà cung cấp theo số lượng nhập</option>
              <option value="document" disabled>Thống kê tài liệu theo số lần mượn (chưa có chức năng)</option>
              <option value="reader" disabled>Thống kê độc giả theo số lần mượn (chưa có chức năng)</option>
            </select>
          </div>
          <h3>Khoảng thời gian thống kê</h3>
          <% if (invalidRange) { %>
            <p class="notice error" id="dateError">
              Ngày bắt đầu không được sau ngày kết thúc. Vui lòng chọn lại khoảng thời gian.
            </p>
          <% } else { %>
            <p class="notice error" id="dateError" hidden>
              Ngày bắt đầu không được sau ngày kết thúc. Vui lòng chọn lại khoảng thời gian.
            </p>
          <% } %>
          <div class="grid">
            <div class="field">
              <label for="from">Từ ngày</label>
              <input id="from" type="date" name="from" value="<%= Html8.escape(from) %>" required>
            </div>
            <div class="field">
              <label for="to">Đến ngày</label>
              <input id="to" type="date" name="to" value="<%= Html8.escape(to) %>" required>
            </div>
          </div>
          <div class="toolbar">
            <button class="btn" type="submit">Xem thống kê</button>
            <a class="btn secondary" href="ManagerHomeFrm8.jsp">Quay lại</a>
          </div>
        </form>
      </section>
    </main>
    <script>
      const statisticsForm = document.getElementById('statisticsForm');
      const fromDate = document.getElementById('from');
      const toDate = document.getElementById('to');
      const dateError = document.getElementById('dateError');

      statisticsForm.addEventListener('submit', function (event) {
        if (fromDate.value > toDate.value) {
          event.preventDefault();
          dateError.hidden = false;
        }
      });

      fromDate.addEventListener('change', function () {
        if (fromDate.value <= toDate.value) dateError.hidden = true;
      });
      toDate.addEventListener('change', function () {
        if (fromDate.value <= toDate.value) dateError.hidden = true;
      });
    </script>
  </body>
</html>
