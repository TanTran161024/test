package org.example.webquanao.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.webquanao.action.Result;
import org.example.webquanao.service.PasswordResetService;

import java.io.IOException;

@WebServlet(name = "ResetPasswordController", value = "/reset-password")
public class ResetPasswordController extends HttpServlet {
    private PasswordResetService passwordResetService;

    @Override
    public void init() {
        passwordResetService = new PasswordResetService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        Result result = passwordResetService.validateToken(token);

        if (result.isSuccess()) {
            request.setAttribute("token", token);
        } else {
            request.setAttribute("error", result.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/resetPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        Result result = passwordResetService.resetPassword(token, password, confirmPassword);
        if (result.isSuccess()) {
            request.setAttribute("message", result.getMessage());
            request.getRequestDispatcher("/WEB-INF/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", result.getMessage());
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/resetPassword.jsp").forward(request, response);
        }
    }
}
