package com.example.chat.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.chat.dto.MessageResponse;
import com.example.chat.dto.ReadReceiptEvent;
import com.example.chat.dto.SendMessageRequest;
import com.example.chat.dto.UserResponse;
import com.example.chat.service.ChatService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/chat")
public class ChatController {
    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    public ChatController(ChatService chatService, SimpMessagingTemplate messagingTemplate) {
        this.chatService = chatService;
        this.messagingTemplate = messagingTemplate;
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
        List<Long> readMessageIds = chatService.markAsReadByEmail(email, otherUserId);

        // لو فيه رسايل اتعلمت كمقروءة، نبلّغ المرسل
        if (!readMessageIds.isEmpty()) {
            String senderEmail = chatService.getUserEmailById(otherUserId);
            ReadReceiptEvent event = new ReadReceiptEvent(
                    // الحقل ده هنحتاجه عشان نعرف مين القارئ
                    // محتاج نجيب الـ userId الحالي (اللي قرأ)
                    chatService.getUserIdByEmail(email),
                    readMessageIds);
            messagingTemplate.convertAndSendToUser(senderEmail, "/queue/reads", event);
        }

        return ResponseEntity.noContent().build();
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserResponse>> getAllUsers(Authentication authentication) {
        return ResponseEntity.ok(chatService.getAllUsersExceptByEmail(authentication.getName()));
    }

    @GetMapping("/unread-counts")
    public ResponseEntity<Map<Long, Long>> getUnreadCounts(Authentication authentication) {
        return ResponseEntity.ok(chatService.getUnreadCountsByEmail(authentication.getName()));
    }

    @GetMapping("/unread-total")
    public ResponseEntity<Long> getUnreadTotal(Authentication authentication) {
        return ResponseEntity.ok(chatService.getUnreadTotalByEmail(authentication.getName()));
    }

}