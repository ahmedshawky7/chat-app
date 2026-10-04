package com.example.chat.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SendMessageRequest(
    @NotNull
    Long receiverId,

    @NotBlank 
    @Size(max = 1000)
    String content
) {
    
}
