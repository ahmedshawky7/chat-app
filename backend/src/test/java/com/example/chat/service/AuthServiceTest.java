package com.example.chat.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.example.chat.dto.LoginRequest;
import com.example.chat.dto.RegisterRequest;
import com.example.chat.entity.User;
import com.example.chat.repository.RefreshTokenRepository;
import com.example.chat.repository.UserRepository;
import com.example.chat.security.JwtService;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private JwtService jwtService;
    @Mock private AuthenticationManager authenticationManager;
    @Mock private RefreshTokenRepository refreshTokenRepository;

    @InjectMocks
    private AuthService authService;

    @Test
    void register_WithValidData_ShouldReturnAuthResponse() {
        RegisterRequest request = new RegisterRequest("ahmed", "ahmed@test.com", "123456");
        
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenAnswer(inv -> {
            User u = inv.getArgument(0);
            u.setId(1L);
            return u;
        });
        when(jwtService.generateToken(any(User.class))).thenReturn("access-token");
        when(jwtService.generateRefreshToken(any(User.class))).thenReturn("refresh-token");

        var response = authService.register(request);

        assertNotNull(response);
        assertEquals("access-token", response.token());
        assertEquals("refresh-token", response.refreshToken());
        assertEquals("ahmed@test.com", response.email());
        assertEquals("ahmed", response.username());
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void register_WithExistingEmail_ShouldThrowException() {
        RegisterRequest request = new RegisterRequest("ahmed", "ahmed@test.com", "123456");
        
        when(userRepository.existsByEmail("ahmed@test.com")).thenReturn(true);

        assertThrows(IllegalArgumentException.class, () -> authService.register(request));
    }
}