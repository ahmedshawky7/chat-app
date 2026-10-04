package com.example.chat.controller;

import java.security.Principal;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.example.chat.dto.MessageResponse;
import com.example.chat.dto.SendMessageRequest;
import com.example.chat.service.ChatService;

@Controller
public class ChatWebSocketController {
    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    public ChatWebSocketController(ChatService chatService, SimpMessagingTemplate messagingTemplate) {
        this.chatService = chatService;
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/chat.send")
    public void handleMessage(@Payload SendMessageRequest request, Principal principal) {
        String senderEmail = principal.getName();
        MessageResponse response = chatService.sendMessageByEmail(senderEmail, request);
        
        // ابعت للمستقبل
        String receiverEmail = chatService.getUserEmailById(request.receiverId());
        messagingTemplate.convertAndSendToUser(receiverEmail, "/queue/messages", response);
        
        // ابعت للمرسل (تأكيد)
        messagingTemplate.convertAndSendToUser(senderEmail, "/queue/messages", response);
    }
}