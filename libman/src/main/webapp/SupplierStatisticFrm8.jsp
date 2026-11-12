<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.time.*,java.time.format.*,java.text.*,java.util.*,vn.libman.module.*,vn.libman.dao.DAO8,vn.libman.dao.ManagerDAO8,vn.libman.util.Html8" %>
<%
Long managerId = (Long) session.getAttribute("managerId");
if (managerId == null) {
  response.sendRedirect("dangnhap.jsp?err=timeout");
  return;
}

LocalDate from;
LocalDate to;
String rawFrom = request.getParameter("from");
String rawTo = request.getParameter("to");
try {
  from = LocalDate.parse(rawFrom);
  to = LocalDate.parse(rawTo);
  if (from.isAfter(to)) {
    throw new IllegalArgumentException("Ngày bắt đầu sau ngày kết thúc");
  }
} catch (Exception e) {
  String url = "SelectStatisticHomeFrm8.jsp?err=date";
  if (rawFrom != null) {
    url += "&from=" + java.net.URLEncoder.encode(rawFrom, java.nio.charset.StandardCharsets.UTF_8);
  }
  if (rawTo != null) {
    url += "&to=" + java.net.URLEncoder.encode(rawTo, java.nio.charset.StandardCharsets.UTF_8);
  }
  response.sendRedirect(url);
  return;
}

List<SupplierStatistic8> rows = new ArrayList<>();
try (Connection connection = DAO8.openConnection()) {
  if (!new ManagerDAO8(connection).isActiveManager(managerId)) {
    session.invalidate();
    response.sendRedirect("dangnhap.jsp?err=role");
    return;
  }
  List<SupplierStatistic8> allRows =
      new vn.libman.dao.SupplierStatisticDAO8(connection).getSupplierStatistic(from, to);
  for (SupplierStatistic8 summary : allRows) {
    if (summary.invoiceCount() > 0) {
      rows.add(summary);
    }
  }
} catch (Exception e) {
  application.log("Supplier statistics", e);
  response.sendError(503, "Không thể tải báo cáo nhà cung cấp");
  return;
}

long totalQuantity = 0;
java.math.BigDecimal totalAmount = java.math.BigDecimal.ZERO;
for (SupplierStatistic8 summary : rows) {
  totalQuantity += summary.totalQuantity();
  if (summary.totalAmount() != null) {
    totalAmount = totalAmount.add(summary.totalAmount());
  }
}
NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8">
    <title>Thống kê nhà cung cấp</title>
    <%@ include file="libman-style.jspf" %>
  </head>
  <body>
    <main class="shell">
      <header class="top">
        <h1>Thống kê nhà cung cấp theo số lượng nhập</h1>
        <a class="btn secondary" href="SelectStatisticHomeFrm8.jsp">Chọn báo cáo</a>
      </header>
      <section class="card">
        <p class="muted">
          Thời gian thống kê:
          <b><%= from.format(dateFormat) %></b> đến <b><%= to.format(dateFormat) %></b>.
        </p>

        <% if (rows.isEmpty()) { %>
          <div class="notice">Không có dữ liệu trong thời gian này.</div>
        <% } else { %>
          <div class="stats">
            <div class="stat">
              Số nhà cung cấp
              <strong><%= rows.size() %></strong>
            </div>
            <div class="stat">
              Tổng số lượng nhập
              <strong><%= money.format(totalQuantity) %></strong>
            </div>
            <div class="stat">
              Tổng giá trị
              <strong><%= money.format(totalAmount) %> ₫</strong>
            </div>
          </div>

          <table>
            <thead>
              <tr>
                <th>STT</th>
                <th>Mã NCC</th>
                <th>Tên nhà cung cấp</th>
                <th>Điện thoại</th>
                <th>Số hóa đơn</th>
                <th>Tổng số lượng nhập</th>
                <th>Tổng tiền</th>
              </tr>
            </thead>
            <tbody>
              <% for (int i = 0; i < rows.size(); i++) {
                   SupplierStatistic8 supplier = rows.get(i);
                   String supplierCode = String.format("NCC%03d", supplier.supplierId()); %>
                <tr class="clickable"
                    onclick="location.href='ImportInvoiceListFrm8.jsp?supplierId=<%= supplier.supplierId() %>&amp;from=<%= from %>&amp;to=<%= to %>'"
                    style="cursor:pointer">
                  <td><%= i + 1 %></td>
                  <td><%= supplierCode %></td>
                  <td>
                    <a class="rowlink"
                       href="ImportInvoiceListFrm8.jsp?supplierId=<%= supplier.supplierId() %>&amp;from=<%= from %>&amp;to=<%= to %>">
                      <%= Html8.escape(supplier.name()) %>
                    </a>
                  </td>
                  <td><%= Html8.escape(supplier.phone()) %></td>
                  <td><%= supplier.invoiceCount() %></td>
                  <td><%= money.format(supplier.totalQuantity()) %></td>
                  <td><%= money.format(supplier.totalAmount()) %> ₫</td>
                </tr>
              <% } %>
            </tbody>
            <tfoot>
              <tr>
                <th colspan="5">Tổng cộng</th>
                <th><%= money.format(totalQuantity) %></th>
                <th><%= money.format(totalAmount) %> ₫</th>
              </tr>
            </tfoot>
          </table>
        <% } %>

        <div class="toolbar">
          <a class="btn secondary" href="SelectStatisticHomeFrm8.jsp">Quay lại</a>
        </div>
      </section>
    </main>
  </body>
</html>
