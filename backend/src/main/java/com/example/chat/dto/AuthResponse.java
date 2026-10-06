package com.example.chat.dto;

public record AuthResponse(
    String token,
    String refreshToken,
    String email,
    String username,
    Long id
) {}