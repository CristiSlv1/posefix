package com.cristislv1.backend.auth;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.http.HttpHeaders;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class SupabaseAuthenticationFilter extends OncePerRequestFilter {

    private final SupabaseAuthService authService;

    public SupabaseAuthenticationFilter(SupabaseAuthService authService) {
        this.authService = authService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);

        try {
            // In a real app we might want to cache this or use a JWT library to verify
            // offline instead of an RPC every request.
            // But per specs, we call Supabase /auth/v1/user
            SupabaseAuthService.SupabaseUser user = authService.getUser(token).block();

            if (user != null) {
                SupabaseAuthenticationToken authentication = new SupabaseAuthenticationToken(user, token);
                // Also set the WebAuthenticationDetails if we needed IP address etc.
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            // Invalid token or downstream service error. We don't populate
            // SecurityContextHolder,
            // so Spring Security will return 401 later since the request requires
            // authentication.
            logger.warn("Supabase Auth Token validation failed: " + e.getMessage());
        }

        filterChain.doFilter(request, response);
    }
}
