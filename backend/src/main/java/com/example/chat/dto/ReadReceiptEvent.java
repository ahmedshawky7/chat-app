package com.example.chat.dto;

import java.util.List;

public record ReadReceiptEvent(
    Long readerId,
    List<Long> messageIds
) {}