package com.example.chat.security;

import static org.junit.jupiter.api.Assertions.*;

import java.util.Base64;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.example.chat.entity.Role;
import com.example.chat.entity.User;

class JwtServiceTest {

    private JwtService jwtService;
    private User testUser;

    @BeforeEach
    void setUp() {
        String secretKey = Base64.getEncoder().encodeToString(
                "my-super-secret-key-for-testing-256bit!!".getBytes()
        );
        jwtService = new JwtService(secretKey, 900000L, 604800000L);
        
        testUser = User.builder()
                .id(1L)
                .username("testuser")
                .email("test@example.com")
                .password("password")
                .role(Role.USER)
                .build();
    }

    @Test
    void generateToken_ShouldReturnValidToken() {
        String token = jwtService.generateToken(testUser);
        
        assertNotNull(token);
        assertFalse(token.isEmpty());
        assertTrue(token.split("\\.").length == 3);  // JWT has 3 parts
    }

    @Test
    void extractUsername_ShouldReturnEmail() {
        String token = jwtService.generateToken(testUser);
        String username = jwtService.extractUsername(token);
        
        assertEquals("test@example.com", username);
    }

    @Test
    void isTokenValid_WithValidToken_ShouldReturnTrue() {
        String token = jwtService.generateToken(testUser);
        
        assertTrue(jwtService.isTokenValid(token, testUser));
    }

    @Test
    void isTokenValid_WithWrongUser_ShouldReturnFalse() {
        String token = jwtService.generateToken(testUser);
        
        User otherUser = User.builder()
                .id(2L)
                .username("other")
                .email("other@example.com")
                .password("password")
                .role(Role.USER)
                .build();
        
        assertFalse(jwtService.isTokenValid(token, otherUser));
    }

    @Test
    void generateRefreshToken_ShouldBeValid() {
        String refreshToken = jwtService.generateRefreshToken(testUser);
        
        assertNotNull(refreshToken);
        assertTrue(jwtService.isTokenValid(refreshToken, testUser));
    }
}