package org.example.webquanao.service;

import org.example.webquanao.action.Result;
import org.example.webquanao.dao.PasswordResetTokenDAO;
import org.example.webquanao.dao.UserDAO;
import org.example.webquanao.entity.PasswordResetToken;
import org.example.webquanao.entity.User;
import org.example.webquanao.utils.PasswordUtil;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.util.Base64;

public class PasswordResetService {
    private static final int TOKEN_EXPIRE_MINUTES = 15;
    private static final int REQUEST_LIMIT_PER_HOUR = 3;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAO();
    private final EmailService emailService = new EmailService();

    public Result requestReset(String email, String baseUrl, String requestIp, String userAgent) {
        email = trim(email);

        if (isBlank(email) || !email.contains("@")) {
            return Result.fail("Email không hợp lệ");
        }

        User user = userDAO.findByEmail(email);
        if (user == null) {
            return Result.fail("Email không tồn tại trong hệ thống. Vui lòng kiểm tra lại");
        }

        if (user.getGoogleId() != null && !user.getGoogleId().isBlank()) {
            return Result.fail("Tài khoản này đăng nhập bằng Google. Vui lòng sử dụng tính năng đăng nhập Google");
        }

        if (!user.isActive()) {
            return Result.fail("Tài khoản của bạn đang bị khóa, không thể đặt lại mật khẩu lúc này");
        }

        if (user.getLockUntil() != null && user.getLockUntil().after(new java.util.Date())) {
            return Result.fail("Tài khoản của bạn đang bị khóa đến " + user.getLockUntil());
        }

        Timestamp requestLimitFrom = new Timestamp(System.currentTimeMillis() - 60L * 60L * 1000L);
        int recentRequests = tokenDAO.countRecentRequests(user.getId(), requestIp, requestLimitFrom);
        if (recentRequests >= REQUEST_LIMIT_PER_HOUR) {
            return Result.fail("Bạn đã gửi yêu cầu quá nhiều lần. Vui lòng thử lại sau");
        }

        String rawToken = generateToken();
        String tokenHash = hashToken(rawToken);
        Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + TOKEN_EXPIRE_MINUTES * 60L * 1000L);

        try {
            tokenDAO.markAllUnusedByUserAsUsed(user.getId());
            tokenDAO.insert(user.getId(), tokenHash, expiresAt, requestIp, limitLength(userAgent, 255));

            String link = baseUrl + "/reset-password?token=" + rawToken;
            String content = "<h3>Xin chào " + escapeHtml(user.getFullName()) + "</h3>"
                    + "<p>Bạn vừa yêu cầu khôi phục mật khẩu.</p>"
                    + "<p>Link đặt lại mật khẩu có hiệu lực trong " + TOKEN_EXPIRE_MINUTES + " phút.</p>"
                    + "<p><a href='" + link + "'>Đặt lại mật khẩu</a></p>"
                    + "<p>Nếu bạn không yêu cầu thao tác này, vui lòng bỏ qua email.</p>";

            emailService.sendEmail(user.getEmail(), "Khôi phục mật khẩu", content);
        } catch (Exception e) {
            e.printStackTrace();
            tokenDAO.markAllUnusedByUserAsUsed(user.getId());
            return Result.fail("Hệ thống gửi email thất bại. Vui lòng thử lại sau");
        }

        return Result.ok("Vui lòng kiểm tra email để đặt lại mật khẩu", null);
    }

    public Result validateToken(String rawToken) {
        if (isBlank(rawToken)) {
            return Result.fail("Đường dẫn không hợp lệ hoặc đã hết hạn");
        }

        PasswordResetToken token = tokenDAO.findValidByHash(hashToken(rawToken));
        if (token == null) {
            return Result.fail("Đường dẫn không hợp lệ hoặc đã hết hạn");
        }

        User user = userDAO.findById(token.getUserId());
        if (user == null || !user.isActive()) {
            return Result.fail("Tài khoản không hợp lệ hoặc đang bị khóa");
        }

        return Result.ok("Token hợp lệ", null);
    }

    public Result resetPassword(String rawToken, String password, String confirmPassword) {
        if (isBlank(rawToken)) {
            return Result.fail("Đường dẫn không hợp lệ hoặc đã hết hạn");
        }

        if (isBlank(password) || isBlank(confirmPassword)) {
            return Result.fail("Vui lòng nhập đầy đủ mật khẩu mới và xác nhận mật khẩu");
        }

        if (!password.equals(confirmPassword)) {
            return Result.fail("Mật khẩu mới không khớp");
        }

        if (password.length() < 6) {
            return Result.fail("Mật khẩu chưa đủ mạnh. Vui lòng nhập ít nhất 6 ký tự");
        }

        PasswordResetToken token = tokenDAO.findValidByHash(hashToken(rawToken));
        if (token == null) {
            return Result.fail("Đường dẫn không hợp lệ hoặc đã hết hạn");
        }

        User user = userDAO.findById(token.getUserId());
        if (user == null || !user.isActive()) {
            return Result.fail("Tài khoản không hợp lệ hoặc đang bị khóa");
        }

        try {
            userDAO.updatePassword(user.getId(), PasswordUtil.hashPassword(password));
            tokenDAO.markUsed(token.getId());
            tokenDAO.markAllUnusedByUserAsUsed(user.getId());
        } catch (Exception e) {
            e.printStackTrace();
            return Result.fail("Cập nhật mật khẩu thất bại. Vui lòng thử lại");
        }

        return Result.ok("Đặt lại mật khẩu thành công. Vui lòng đăng nhập bằng mật khẩu mới", null);
    }

    private String generateToken() {
        byte[] bytes = new byte[32];
        SECURE_RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hashToken(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashed = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
            StringBuilder builder = new StringBuilder();
            for (byte b : hashed) {
                builder.append(String.format("%02x", b));
            }
            return builder.toString();
        } catch (Exception e) {
            throw new RuntimeException("Cannot hash token", e);
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String limitLength(String value, int maxLength) {
        if (value == null) {
            return null;
        }
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }

    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
}
