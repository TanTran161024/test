<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Quên mật khẩu</title>
</head>
<body>
<h2>Quên mật khẩu</h2>

<% if (request.getAttribute("message") != null) { %>
    <p style="color: green;"><%= request.getAttribute("message") %></p>
<% } %>

<% if (request.getAttribute("error") != null) { %>
    <p style="color: red;"><%= request.getAttribute("error") %></p>
<% } %>

<form action="<%= request.getContextPath() %>/forgot-password" method="post">
    <p>Email</p>
    <input type="email" name="email" placeholder="Nhập email" value="<%= request.getAttribute("email") == null ? "" : request.getAttribute("email") %>" required />

    <br><br>
    <button type="submit">Gửi yêu cầu</button>
</form>

<br>
<a href="<%= request.getContextPath() %>/login">Quay lại đăng nhập</a>
</body>
</html>
