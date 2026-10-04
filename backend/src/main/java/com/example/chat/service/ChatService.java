package com.example.chat.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.chat.dto.MessageResponse;
import com.example.chat.dto.SendMessageRequest;
import com.example.chat.dto.UserResponse;
import com.example.chat.entity.Message;
import com.example.chat.entity.User;
import com.example.chat.repository.MessageRepository;
import com.example.chat.repository.UserRepository;

import org.springframework.transaction.annotation.Transactional;

@Service
public class ChatService {
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    public ChatService(MessageRepository messageRepository, UserRepository userRepository) {
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
    }

    public MessageResponse sendMessage(Long senderId, SendMessageRequest request) {
        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Sender not found"));
        User receiver = userRepository.findById(request.receiverId())
                .orElseThrow(() -> new IllegalArgumentException("Receiver not found"));
        if (sender.getId().equals(receiver.getId())) {
            throw new IllegalArgumentException("Cannot send message to yourself");
        }

        Message message = Message.builder()
                .sender(sender)
                .receiver(receiver)
                .content(request.content())
                .isRead(false)
                .build();
        messageRepository.save(message);
        MessageResponse response = new MessageResponse(
                message.getId(),
                message.getContent(),
                sender.getId(),
                sender.getUsername(),
                receiver.getId(),
                message.getTimestamp(),
                message.isRead());
        return response;
    }

    public List<MessageResponse> getConversation(Long userId1, Long userId2) {
        List<Message> messages = messageRepository.findConversation(userId1, userId2);
        return messages.stream()
                .map(message -> new MessageResponse(
                        message.getId(),
                        message.getContent(),
                        message.getSender().getId(),
                        message.getSender().getUsername(),
                        message.getReceiver().getId(),
                        message.getTimestamp(),
                        message.isRead()))
                .toList();
    }

    @Transactional
    public void markAsRead(Long userId, Long otherUserId) {
        messageRepository.markMessagesAsRead(userId, otherUserId);
    }

    public List<MessageResponse> getConversationByEmail(String email, Long otherUserId) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return getConversation(user.getId(), otherUserId);
    }

    public MessageResponse sendMessageByEmail(String email, SendMessageRequest request) {
        User sender = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return sendMessage(sender.getId(), request);
    }

    @Transactional
    public void markAsReadByEmail(String email, Long otherUserId) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        markAsRead(user.getId(), otherUserId);
    }

    public String getUserEmailById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"))
                .getEmail();
    }

    public List<UserResponse> getAllUsersExcept(Long currentUserId) {
        return userRepository.findAllExcept(currentUserId)
                .stream()
                .map(u -> new UserResponse(u.getId(), u.getUsername(), u.getEmail()))
                .toList();
    }

    // في ChatService
    public List<UserResponse> getAllUsersExceptByEmail(String email) {
        User current = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return getAllUsersExcept(current.getId());
    }
}
