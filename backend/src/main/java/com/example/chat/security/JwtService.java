package com.example.chat.security;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import com.example.chat.entity.User;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

@Service
public class JwtService {
    private final SecretKey secretKey;
    private final long accessTokenExpiration;
    private final long refreshTokenExpiration;

    public JwtService(
            @Value("${application.security.jwt.secret-key}") String secretKeyString,
            @Value("${application.security.jwt.access-token-expiration}") long accessTokenExpiration,
            @Value("${application.security.jwt.refresh-token-expiration}") long refreshTokenExpiration) {
        this.secretKey = Keys.hmacShaKeyFor(Decoders.BASE64.decode(secretKeyString));
        this.accessTokenExpiration = accessTokenExpiration;
        this.refreshTokenExpiration = refreshTokenExpiration;
    }

    // ============ Access Token ============
    public String generateToken(User user) {
        return buildToken(new HashMap<>(), user, accessTokenExpiration);
    }

    // ============ Refresh Token ============
    public String generateRefreshToken(User user) {
        return buildToken(new HashMap<>(), user, refreshTokenExpiration);
    }

    // ============ Helpers ============
    private String buildToken(Map<String, Object> extraClaims, UserDetails userDetails, long expiration) {
        var issuedAt = new Date(System.currentTimeMillis());
        var expirationDate = new Date(System.currentTimeMillis() + expiration);
        return Jwts.builder()
                .claims(extraClaims)
                .subject(userDetails.getUsername())
                .issuedAt(issuedAt)
                .expiration(expirationDate)
                .signWith(secretKey)
                .compact();
    }

    public String extractUsername(String token) {
        return extractAllClaims(token).getSubject();
    }

    public boolean isTokenValid(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return username.equals(userDetails.getUsername()) && !isTokenExpired(token);
    }

    private boolean isTokenExpired(String token) {
        return extractAllClaims(token).getExpiration().before(new Date());
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}