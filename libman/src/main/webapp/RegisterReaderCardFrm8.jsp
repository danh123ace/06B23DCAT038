<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.time.*,java.time.format.*,java.util.*,vn.libman.module.*,vn.libman.dao.*,vn.libman.util.Html8" %>
<%
Long readerId=(Long)session.getAttribute("readerId");

if(readerId==null){response.sendRedirect("dangnhap.jsp?err=timeout");
return;
}
Reader8 reader=null;

Optional<ReaderCard8> card=Optional.empty();

String loadError=null;

try(Connection connection=DAO8.openConnection()){
reader=new ReaderDAO8(connection).getReaderProfile(readerId);

card=new ReaderCardDAO8(connection).getCurrentCard(readerId);

}catch(Exception e){
application.log("Load reader-card form",e);

loadError="Không tải được hồ sơ bạn đọc. Kiểm tra kết nối cơ sở dữ liệu.";

}
ReaderCard8 issued=(ReaderCard8)session.getAttribute("issuedCard");

String error=(String)session.getAttribute("registrationError");

session.removeAttribute("registrationError");

DateTimeFormatter dateFmt=DateTimeFormatter.ofPattern("dd/MM/yyyy");

%>
<!DOCTYPE html>
<html lang="vi">
  <head><meta charset="UTF-8"><title>Đăng ký thẻ bạn đọc</title><%@ include file="libman-style.jspf" %>
  </head>
  <body>
    <main class="shell">
      <header class="top">
        <h1>Đăng ký thẻ bạn đọc</h1><a class="btn secondary" href="ReaderHomeFrm8.jsp">Trang chủ</a>
        </header>
        <section class="card">
          <p class="muted">Xin chào, <%=Html8.escape(session.getAttribute("fullName"))%>
          </p>
          <%if(issued!=null){%>
          <div class="notice ok"><strong>Đăng ký thẻ thành công</strong> — mã thẻ <b><%=Html8.escape(issued.cardCode())%>
            </b>, hiệu lực đến <%=issued.expiryDate().format(dateFmt)%>.</div><%session.removeAttribute("issuedCard");
            }%>
            <%if(error!=null){%>
            <div class="notice error"><%=Html8.escape(error)%>
            </div><%}%>
            <%if(loadError!=null){%>
            <div class="notice error"><%=Html8.escape(loadError)%>
            </div><%}%>
            <%if(reader!=null){%>
            <h3>1. Thông tin hồ sơ bạn đọc</h3>
              <%if(card.isPresent()&&"ACTIVE".equalsIgnoreCase(card.get().status())&&card.get().expiryDate()!=null&&!card.get().expiryDate().isBefore(LocalDate.now())){%>
              <div class="notice ok">Bạn đã có thẻ đang hoạt động: <b><%=Html8.escape(card.get().cardCode())%>
                </b> (hết hạn <%=card.get().expiryDate().format(dateFmt)%>).</div>
                <%}else{%>
                <form method="post" action="DoRegisterReaderCard8.jsp">
                  <div class="grid">
                    <div class="field">
                      <label>Họ và tên</label><input value="<%=Html8.escape(reader.fullName())%>" readonly>
                      </div>
                      <div class="field">
                        <label>Ngày sinh</label><input value="<%=reader.dob()==null?"":reader.dob().format(dateFmt)%>" readonly>
                        </div>
                        <div class="field">
                          <label>Địa chỉ liên hệ (*)</label><input name="address" value="<%=Html8.escape(reader.address())%>" required maxlength="300">
                          </div>
                          <div class="field">
                            <label>Số điện thoại (*)</label><input name="phone" value="<%=Html8.escape(reader.phone())%>" required maxlength="40">
                            </div>
                            <div class="field">
                              <label>Email (*)</label><input type="email" name="email" value="<%=Html8.escape(reader.email())%>" required maxlength="160">
                              </div>
                              <div class="field">
                                <label>Loại thẻ bạn đọc</label><select name="cardType" required><option value="STANDARD">Thẻ thường</option><option value="STUDENT">Thẻ sinh viên</option></select>
                                </div>
                              </div>
                              <h3 style="margin-top:28px">2. Quy định sử dụng thẻ thư viện &amp; cam kết</h3>
                                <div class="notice">Thẻ có thời hạn 01 năm từ ngày cấp. Bạn đọc có trách nhiệm bảo quản thẻ, trả tài liệu đúng hạn và thanh toán các khoản phí phát sinh.</div>
                                  <p>
                                    <label><input type="checkbox" name="agree" value="yes" required> Tôi đã đọc, hiểu rõ và đồng ý với quy định sử dụng thẻ thư viện LibMan.</label>
                                    </p>
                                    <div class="toolbar"><button class="btn" type="submit">Đăng ký thẻ</button><a class="btn secondary" href="ReaderHomeFrm8.jsp">Quay lại</a>
                                    </div>
                                  </form><%}%>
                                  <%}%>
                                </section>
                              </main>
                            </body>
                          </html>
