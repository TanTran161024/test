<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Đặt lại mật khẩu</title>
</head>
<body>
<h2>Đặt lại mật khẩu</h2>

<% if (request.getAttribute("error") != null) { %>
    <p style="color: red;"><%= request.getAttribute("error") %></p>
<% } %>

<% if (request.getAttribute("token") != null) { %>
    <form action="<%= request.getContextPath() %>/reset-password" method="post">
        <input type="hidden" name="token" value="<%= request.getAttribute("token") %>" />

        <p>Mật khẩu mới</p>
        <input type="password" name="password" placeholder="Nhập mật khẩu mới" required />

        <p>Xác nhận mật khẩu mới</p>
        <input type="password" name="confirmPassword" placeholder="Nhập lại mật khẩu mới" required />

        <br><br>
        <button type="submit">Lưu thay đổi</button>
    </form>
<% } %>

<br>
<a href="<%= request.getContextPath() %>/forgot-password">Gửi lại yêu cầu khôi phục</a>
</body>
</html>
