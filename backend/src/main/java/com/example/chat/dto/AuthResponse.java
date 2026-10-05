package com.example.chat.dto;

public record AuthResponse(
    String token,
    String email,
    String username,
    Long id
) {}