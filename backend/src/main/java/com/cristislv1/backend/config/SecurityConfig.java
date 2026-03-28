package com.cristislv1.backend.config;

import com.cristislv1.backend.auth.SupabaseAuthenticationFilter;
import com.cristislv1.backend.auth.SupabaseAuthService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {
        private final SupabaseAuthService authService;

        public SecurityConfig(SupabaseAuthService authService) {
                this.authService = authService;
        }

        @Bean
        public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
                http
                                .csrf(csrf -> csrf.disable())
                                .sessionManagement(session -> session.sessionCreationPolicy(
                                                org.springframework.security.config.http.SessionCreationPolicy.STATELESS))
                                .authorizeHttpRequests(auth -> auth
                                                .requestMatchers("/health", "/health/**").permitAll()
                                                .requestMatchers("/exercises", "/exercises/**").permitAll()
                                                .anyRequest().authenticated())
                                .addFilterBefore(new SupabaseAuthenticationFilter(authService),
                                                org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter.class)
                                .formLogin(form -> form.disable())
                                .httpBasic(basic -> basic.disable());

                return http.build();
        }
}