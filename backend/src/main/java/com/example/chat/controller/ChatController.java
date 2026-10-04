package com.example.chat.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.chat.dto.MessageResponse;
import com.example.chat.dto.SendMessageRequest;
import com.example.chat.dto.UserResponse;
import com.example.chat.service.ChatService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/chat")
public class ChatController {
    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

 @PostMapping("/send")
public ResponseEntity<MessageResponse> sendMessage(
        @Valid @RequestBody SendMessageRequest request,
        Authentication authentication) {
    String email = authentication.getName();
    return ResponseEntity.ok(chatService.sendMessageByEmail(email, request));
}

    @GetMapping("/conversation/{otherUserId}")
public ResponseEntity<List<MessageResponse>> getConversation(
        @PathVariable Long otherUserId,
        Authentication authentication) {
    String email = authentication.getName();
    return ResponseEntity.ok(chatService.getConversationByEmail(email, otherUserId));
}

@PostMapping("/read/{otherUserId}")
public ResponseEntity<Void> markAsRead(
        @PathVariable Long otherUserId,
        Authentication authentication) {
    String email = authentication.getName();
    chatService.markAsReadByEmail(email, otherUserId);
    return ResponseEntity.noContent().build();
}

@GetMapping("/users")
public ResponseEntity<List<UserResponse>> getAllUsers(Authentication authentication) {
    return ResponseEntity.ok(chatService.getAllUsersExceptByEmail(authentication.getName()));
}

}