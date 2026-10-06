package com.example.chat.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.chat.entity.Message;

public interface MessageRepository extends JpaRepository<Message, Long> {

        @Query("SELECT m FROM Message m " +
                        "JOIN FETCH m.sender " +
                        "JOIN FETCH m.receiver " +
                        "WHERE (m.sender.id = :userId1 AND m.receiver.id = :userId2) OR " +
                        "(m.sender.id = :userId2 AND m.receiver.id = :userId1) " +
                        "ORDER BY m.timestamp ASC")
        List<Message> findConversation(@Param("userId1") Long userId1, @Param("userId2") Long userId2);

        @Modifying
        @Query("UPDATE Message m SET m.isRead = true " +
                        "WHERE m.receiver.id = :receiverId AND m.sender.id = :senderId AND m.isRead = false")
        void markMessagesAsRead(@Param("receiverId") Long receiverId, @Param("senderId") Long senderId);

        @Query("SELECT m.sender.id, COUNT(m) FROM Message m " +
                        "WHERE m.receiver.id = :receiverId AND m.isRead = false " +
                        "GROUP BY m.sender.id")
        List<Object[]> countUnreadBySender(@Param("receiverId") Long receiverId);

        @Query("SELECT m.id FROM Message m " +
                        "WHERE m.receiver.id = :receiverId " +
                        "AND m.sender.id = :senderId " +
                        "AND m.isRead = false")
        List<Long> findUnreadMessageIds(@Param("receiverId") Long receiverId, @Param("senderId") Long senderId);

        long countByReceiverIdAndIsReadFalse(Long receiverId);
}