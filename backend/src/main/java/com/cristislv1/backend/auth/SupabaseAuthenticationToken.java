package com.cristislv1.backend.auth;

import org.springframework.security.authentication.AbstractAuthenticationToken;

import java.util.Collections;

public class SupabaseAuthenticationToken extends AbstractAuthenticationToken {

    private final SupabaseAuthService.SupabaseUser user;
    private final String token;

    public SupabaseAuthenticationToken(SupabaseAuthService.SupabaseUser user, String token) {
        super(Collections.emptyList()); // No authorities/roles needed currently
        this.user = user;
        this.token = token;
        setAuthenticated(true);
    }

    @Override
    public Object getCredentials() {
        return token;
    }

    @Override
    public Object getPrincipal() {
        return user;
    }
    
    public String getUserId() {
        return user.id();
    }
}
