package com.example.chat.dto;

public record UserResponse(
    Long id,
    String username,
    String email
) {}