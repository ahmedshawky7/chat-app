package com.example.chat.dto;

import java.time.LocalDateTime;

public record MessageResponse(
    Long id,
    String content,
    Long senderId,
    String senderUsername,
    Long receiverId,
    LocalDateTime timestamp,
    boolean isRead
) {
    
}
