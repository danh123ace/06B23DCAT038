<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
  <head><meta charset="UTF-8"><title>Đăng nhập LibMan</title><%@ include file="libman-style.jspf" %>
  </head>
  <body>
    <main class="shell">
      <header class="top">
        <h1>Hệ thống quản lý thư viện LibMan</h1>
        </header>
        <section class="card" style="max-width:520px;margin:auto">
          <h2>Đăng nhập</h2>
            <p class="muted">Đăng nhập bằng tài khoản Manager8 hoặc Reader8.</p>
              <% String error=(String)session.getAttribute("loginError");
              session.removeAttribute("loginError");
              if(error!=null){ %>
              <div class="notice error"><%=vn.libman.util.Html8.escape(error)%>
              </div><% } %>
              <form method="post" action="DoLogin8.jsp">
                <div class="field">
                  <label for="username">Tên đăng nhập</label><input id="username" name="username" required autocomplete="username">
                  </div>
                  <div class="field" style="margin-top:14px">
                    <label for="password">Mật khẩu</label><input id="password" name="password" type="password" required autocomplete="current-password">
                    </div>
                    <div class="toolbar"><button class="btn" type="submit">Đăng nhập</button>
                    </div>
                  </form>
                </section>
              </main>
            </body>
          </html>
