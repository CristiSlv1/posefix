package com.cristislv1.backend.auth;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class SupabaseAuthService {

    private final WebClient client;

    public SupabaseAuthService(
            @Value("${supabase.url}") String supabaseUrl,
            @Value("${supabase.serviceKey}") String serviceKey) {
        this.client = WebClient.builder()
                .baseUrl(supabaseUrl)
                .defaultHeader("apikey", serviceKey)
                .build();
    }

    public Mono<SupabaseUser> getUser(String accessToken) {
        return client.get()
                .uri("/auth/v1/user")
                .header("Authorization", "Bearer " + accessToken)
                .retrieve()
                .bodyToMono(SupabaseUser.class);
    }

    public static class SupabaseUser {
        private String id;
        private String email;

        public SupabaseUser() {
        }

        public SupabaseUser(String id, String email) {
            this.id = id;
            this.email = email;
        }

        public String id() {
            return id;
        }

        public String email() {
            return email;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }
    }
}