package com.cristislv1.backend.auth;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestController
public class AuthController {

    private final SupabaseAuthService auth;

    public AuthController(SupabaseAuthService auth) {
        this.auth = auth;
    }

    @GetMapping("/me")
    public Map<String, Object> me(
            @org.springframework.security.core.annotation.AuthenticationPrincipal SupabaseAuthService.SupabaseUser user) {
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid user");
        }
        return Map.of("id", user.id(), "email", user.email());
    }
}