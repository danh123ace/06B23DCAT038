<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.time.*,java.time.format.*,java.text.*,java.util.*,vn.libman.module.*,vn.libman.dao.DAO8,vn.libman.dao.ManagerDAO8,vn.libman.util.Html8" %>
<% Long managerId=(Long)session.getAttribute("managerId");
if(managerId==null){response.sendRedirect("dangnhap.jsp?err=timeout");
return;
}
long supplierId;
LocalDate from,to;
try{supplierId=Long.parseLong(request.getParameter("supplierId"));
from=LocalDate.parse(request.getParameter("from"));
to=LocalDate.parse(request.getParameter("to"));
if(supplierId<=0||from.isAfter(to))throw new IllegalArgumentException();
}catch(Exception e){response.sendRedirect("SelectStatisticHomeFrm8.jsp?err=parameter");
return;
}
List<ImportInvoice8> rows;
String supplierName="Nhà cung cấp";
try(Connection c=DAO8.openConnection()){if(!new ManagerDAO8(c).isActiveManager(managerId)){session.invalidate();
response.sendRedirect("dangnhap.jsp?err=role");
return;
}rows=new vn.libman.dao.ImportInvoiceDAO8(c).getInvoiceBySupplier(supplierId,from,to);
for(SupplierStatistic8 s:new vn.libman.dao.SupplierStatisticDAO8(c).getSupplierStatistic(from,to))if(s.supplierId()==supplierId){supplierName=s.name();
break;
}}catch(Exception e){application.log("Import invoice list",e);
response.sendError(503,"Không thể tải danh sách hóa đơn");
return;
}
NumberFormat money=NumberFormat.getNumberInstance(new Locale("vi","VN"));
DateTimeFormatter df=DateTimeFormatter.ofPattern("dd/MM/yyyy");
long quantity=0;
java.math.BigDecimal amount=java.math.BigDecimal.ZERO;
for(ImportInvoice8 invoiceSummary:rows){quantity+=invoiceSummary.totalQuantity();
if(invoiceSummary.totalAmount()!=null)amount=amount.add(invoiceSummary.totalAmount());
}%>
<!DOCTYPE html>
<html lang="vi">
  <head><meta charset="UTF-8"><title>Hóa đơn nhập - LibMan</title><%@ include file="libman-style.jspf" %>
  </head>
  <body>
    <main class="shell">
      <header class="top">
        <h1>Chi tiết các lần nhập tài liệu</h1><a class="btn secondary" href="SupplierStatisticFrm8.jsp?from=<%=from%>&amp;to=<%=to%>">Quay lại</a>
        </header>
        <section class="card">
          <p><b>Nhà cung cấp:</b> <%=Html8.escape(supplierName)%> (Mã NCC: NCC<%=String.format("%03d",supplierId)%>)</p>
            <p class="muted">Thời gian lọc: <%=from.format(df)%> – <%=to.format(df)%>
            </p>
            <table>
              <thead>
                <tr>
                  <th>STT</th>
                    <th>Mã hóa đơn</th>
                      <th>Ngày nhập</th>
                        <th>Mã NV nhập</th>
                          <th>Số lượng</th>
                            <th>Tổng tiền (VND)</th>
                            </tr>
                          </thead>
                          <tbody>
                            <%if(rows.isEmpty()){%>
                            <tr>
                              <td colspan="6" class="muted">Không có hóa đơn trong thời gian đã chọn.</td>
                              </tr><%}else{for(int i=0;
                              i<rows.size();
                              i++){ImportInvoice8 invoice=rows.get(i);
                              %>
                              <tr class="clickable" style="cursor:pointer" onclick="location.href='ImportInvoiceDetailFrm8.jsp?invoiceId=<%=invoice.importInvoiceId()%>&amp;supplierId=<%=supplierId%>&amp;from=<%=from%>&amp;to=<%=to%>'">
                                <td><%=i+1%>
                                </td>
                                <td><a class="rowlink" href="ImportInvoiceDetailFrm8.jsp?invoiceId=<%=invoice.importInvoiceId()%>&amp;supplierId=<%=supplierId%>&amp;from=<%=from%>&amp;to=<%=to%>"><%=Html8.escape(invoice.invoiceCode())%>
                                  </a>
                                </td>
                                <td><%=invoice.importDate().format(df)%>
                                </td>
                                <td>NV<%=String.format("%03d",invoice.librarianId())%>
                                </td>
                                <td><%=money.format(invoice.totalQuantity())%>
                                </td>
                                <td><%=money.format(invoice.totalAmount())%>
                                </td>
                              </tr><%}}%>
                            </tbody>
                            <tfoot>
                              <tr>
                                <th colspan="4">Tổng cộng: <%=rows.size()%> lần nhập</th>
                                  <th><%=money.format(quantity)%>
                                  </th>
                                  <th><%=money.format(amount)%>
                                  </th>
                                </tr>
                              </tfoot>
                            </table>
                            <div class="toolbar"><a class="btn secondary" href="SupplierStatisticFrm8.jsp?from=<%=from%>&amp;to=<%=to%>">Quay lại báo cáo</a>
                            </div>
                          </section>
                        </main>
                      </body>
                    </html>
