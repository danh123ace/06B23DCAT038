<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.util.*,vn.libman.dao.*,org.mindrot.jbcrypt.BCrypt" %>
<% request.setCharacterEncoding("UTF-8");

String username=request.getParameter("username"), password=request.getParameter("password");

try(Connection c=DAO8.openConnection()){
Optional<LoginAccount8> account=new AccountDAO8(c).getByUsername(username==null?"":username.trim());

String storedHash=account.isEmpty()?null:account.get().passwordHash();

// PHP password_hash uses the $2y$ prefix;
// jBCrypt expects the equivalent $2a$ prefix.
if(storedHash!=null && storedHash.startsWith("$2y$")) storedHash="$2a$"+storedHash.substring(4);

if(account.isEmpty() || password==null || storedHash==null || !BCrypt.checkpw(password,storedHash)){
session.setAttribute("loginError","Tên đăng nhập hoặc mật khẩu không đúng.");
response.sendRedirect("dangnhap.jsp");
return;

}
LoginAccount8 a=account.get();
session.invalidate();
session=request.getSession(true);

session.setAttribute("userId",a.userId());
session.setAttribute("username",a.username());
session.setAttribute("fullName",a.fullName());

if("READER".equals(a.role()) && a.readerId()!=null){session.setAttribute("readerId",a.readerId());
response.sendRedirect("ReaderHomeFrm8.jsp");
return;
}
if("MANAGER".equals(a.role()) && a.managerId()!=null && new ManagerDAO8(c).isActiveManager(a.managerId())){session.setAttribute("managerId",a.managerId());
response.sendRedirect("ManagerHomeFrm8.jsp");
return;
}
session.invalidate();
response.sendRedirect("dangnhap.jsp?err=role");

}catch(Exception e){application.log("Login failure",e);
session.setAttribute("loginError","Không thể đăng nhập. Kiểm tra cơ sở dữ liệu và các stored procedure.");
response.sendRedirect("dangnhap.jsp");
}
%>
