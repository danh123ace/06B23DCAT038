<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.time.*,java.util.*,java.util.regex.*,vn.libman.module.*,vn.libman.dao.*" %>
<%
request.setCharacterEncoding("UTF-8");

Long readerId=(Long)session.getAttribute("readerId");

if(readerId==null){response.sendRedirect("dangnhap.jsp?err=timeout");
return;
}
if(!"POST".equalsIgnoreCase(request.getMethod())){response.sendRedirect("RegisterReaderCardFrm8.jsp");
return;
}
String address=request.getParameter("address"), email=request.getParameter("email"), phone=request.getParameter("phone"), cardType=request.getParameter("cardType");

String error=null;

if(readerId<=0) error="Bạn đọc không hợp lệ";

else if(address==null||address.isBlank()) error="Địa chỉ liên hệ không được để trống";

else if(email==null||!Pattern.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$",email.trim())) error="Email không đúng định dạng";

else if(phone==null||!Pattern.matches("^[+0-9() .-]{7,20}$",phone.trim())) error="Số điện thoại không đúng định dạng";

else if(cardType==null||!("STANDARD".equals(cardType)||"STUDENT".equals(cardType))) error="Vui lòng chọn loại thẻ hợp lệ";

else if(!"yes".equals(request.getParameter("agree"))) error="Bạn cần đồng ý với quy định sử dụng thẻ";

if(error!=null){session.setAttribute("registrationError",error);
response.sendRedirect("RegisterReaderCardFrm8.jsp");
return;
}
ReaderCard8 issuedCard;

try(Connection connection=DAO8.openConnection()){
connection.setAutoCommit(false);

try{
ReaderDAO8 readerDao=new ReaderDAO8(connection);

ReaderCardDAO8 cardDao=new ReaderCardDAO8(connection);

Reader8 reader=readerDao.getReaderProfile(readerId);

Optional<ReaderCard8> current=cardDao.getCurrentCard(readerId);

if(current.isPresent()){
ReaderCard8 currentCard=current.get();

if("ACTIVE".equalsIgnoreCase(currentCard.status())&&currentCard.expiryDate()!=null&&!currentCard.expiryDate().isBefore(LocalDate.now()))
throw new IllegalArgumentException("Bạn đọc đang có thẻ còn hiệu lực");

if("ACTIVE".equalsIgnoreCase(currentCard.status())) cardDao.markExpired(currentCard.readerCardId());

}
String normalizedAddress=address.trim(), normalizedEmail=email.trim(), normalizedPhone=phone.trim();

if(!Objects.equals(reader.address(),normalizedAddress)||!Objects.equals(reader.email(),normalizedEmail)||!Objects.equals(reader.phone(),normalizedPhone))
readerDao.updateContactInfo(readerId,normalizedAddress,normalizedEmail,normalizedPhone);

issuedCard=cardDao.createCard(readerId,cardType);

connection.commit();

}catch(Exception e){
try{connection.rollback();
}catch(SQLException rollbackError){e.addSuppressed(rollbackError);
}
if(e instanceof RuntimeException) throw (RuntimeException)e;

throw new IllegalStateException("Không thể hoàn tất đăng ký thẻ",e);

}
}catch(Exception e){
application.log("Reader card registration",e);

String message=e.getMessage();

session.setAttribute("registrationError",message==null||message.isBlank()?"Đăng ký thẻ không thành công. Kiểm tra kết nối cơ sở dữ liệu.":message);

response.sendRedirect("RegisterReaderCardFrm8.jsp");
return;

}
session.setAttribute("issuedCard",issuedCard);

response.sendRedirect("RegisterReaderCardFrm8.jsp?success=1");

%>
