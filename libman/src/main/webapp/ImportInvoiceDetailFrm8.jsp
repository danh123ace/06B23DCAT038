<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.time.*,java.time.format.*,java.text.*,java.util.*,vn.libman.module.*,vn.libman.dao.DAO8,vn.libman.dao.ManagerDAO8,vn.libman.util.Html8" %>
<% Long managerId=(Long)session.getAttribute("managerId");
if(managerId==null){response.sendRedirect("dangnhap.jsp?err=timeout");
return;
}
long invoiceId,supplierId;
LocalDate from,to;
try{invoiceId=Long.parseLong(request.getParameter("invoiceId"));
supplierId=Long.parseLong(request.getParameter("supplierId"));
from=LocalDate.parse(request.getParameter("from"));
to=LocalDate.parse(request.getParameter("to"));
if(invoiceId<=0||supplierId<=0||from.isAfter(to))throw new IllegalArgumentException();
}catch(Exception e){response.sendRedirect("ManagerHomeFrm8.jsp?err=parameter");
return;
}
List<ImportInvoice8> invoices;
List<ImportInvoiceDetail8> details;
try(Connection c=DAO8.openConnection()){if(!new ManagerDAO8(c).isActiveManager(managerId)){session.invalidate();
response.sendRedirect("dangnhap.jsp?err=role");
return;
}invoices=new vn.libman.dao.ImportInvoiceDAO8(c).getInvoiceBySupplier(supplierId,from,to);
ImportInvoice8 found=null;
for(ImportInvoice8 i:invoices)if(i.importInvoiceId()==invoiceId)found=i;
if(found==null){response.sendError(404,"Không tìm thấy hóa đơn");
return;
}details=new vn.libman.dao.ImportInvoiceDetailDAO8(c).getDetailByImportInvoice(invoiceId);
}catch(Exception e){application.log("Import invoice detail",e);
response.sendError(503,"Không thể tải chi tiết hóa đơn");
return;
}
ImportInvoice8 invoice=null;
for(ImportInvoice8 i:invoices)if(i.importInvoiceId()==invoiceId)invoice=i;
NumberFormat money=NumberFormat.getNumberInstance(new Locale("vi","VN"));
DateTimeFormatter df=DateTimeFormatter.ofPattern("dd/MM/yyyy");
long quantity=0;
java.math.BigDecimal amount=java.math.BigDecimal.ZERO;
for(ImportInvoiceDetail8 line:details){quantity+=line.quantity();
amount=amount.add(line.lineAmount());
}%>
<!DOCTYPE html>
<html lang="vi">
  <head><meta charset="UTF-8"><title>Chi tiết hóa đơn nhập</title><%@ include file="libman-style.jspf" %>
  </head>
  <body>
    <main class="shell">
      <header class="top">
        <h1>Chi tiết hóa đơn nhập tài liệu</h1><a class="btn secondary" href="ImportInvoiceListFrm8.jsp?supplierId=<%=supplierId%>&amp;from=<%=from%>&amp;to=<%=to%>">Quay lại</a>
        </header>
        <section class="card">
          <div class="grid">
            <div><b>Mã hóa đơn:</b> <%=Html8.escape(invoice.invoiceCode())%>
            </div>
            <div><b>Ngày nhập:</b> <%=invoice.importDate().format(df)%>
            </div>
            <div><b>Mã nhân viên nhập:</b> NV<%=String.format("%03d",invoice.librarianId())%>
            </div>
            <div><b>Ghi chú:</b> <%=Html8.escape(invoice.note())%>
            </div>
          </div>
          <table>
            <thead>
              <tr>
                <th>STT</th>
                  <th>Mã tài liệu</th>
                    <th>Tên tài liệu</th>
                      <th>Nhà xuất bản</th>
                        <th>Số lượng</th>
                          <th>Đơn giá</th>
                            <th>Thành tiền</th>
                            </tr>
                          </thead>
                          <tbody>
                            <%if(details.isEmpty()){%>
                            <tr>
                              <td colspan="7" class="muted">Hóa đơn chưa có dòng tài liệu.</td>
                              </tr><%}else{for(int i=0;
                              i<details.size();
                              i++){ImportInvoiceDetail8 d=details.get(i);
                              %>
                              <tr>
                                <td><%=i+1%>
                                </td>
                                <td>TL<%=String.format("%04d",d.document().documentId())%>
                                </td>
                                <td><%=Html8.escape(d.document().title())%>
                                </td>
                                <td><%=Html8.escape(d.document().publisher())%>
                                </td>
                                <td><%=money.format(d.quantity())%>
                                </td>
                                <td><%=money.format(d.unitPrice())%>
                                </td>
                                <td><%=money.format(d.lineAmount())%>
                                </td>
                              </tr><%}}%>
                            </tbody>
                            <tfoot>
                              <tr>
                                <th colspan="4">Tổng số lượng tài liệu: <%=money.format(quantity)%>
                                </th>
                                <th><%=money.format(quantity)%>
                                </th>
                                <th colspan="2">Tổng tiền: <%=money.format(amount)%> VND</th>
                                </tr>
                              </tfoot>
                            </table>
                            <div class="toolbar"><a class="btn secondary" href="ImportInvoiceListFrm8.jsp?supplierId=<%=supplierId%>&amp;from=<%=from%>&amp;to=<%=to%>">Quay lại danh sách nhập</a>
                            </div>
                          </section>
                        </main>
                      </body>
                    </html>
