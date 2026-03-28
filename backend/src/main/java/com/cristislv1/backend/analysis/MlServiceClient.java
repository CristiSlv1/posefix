package com.cristislv1.backend.analysis;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@Service
public class MlServiceClient {

    private final WebClient client;
    private static final Logger logger = LoggerFactory.getLogger(MlServiceClient.class);

    public MlServiceClient(@Value("${app.ml-service.url}") String mlServiceUrl) {
        this.client = WebClient.builder()
                .baseUrl(mlServiceUrl)
                .build();
    }

    public MlAnalysisResponse analyzeVideo(String absoluteFilePath, Long exerciseId) {
        try {
            return client.post()
                    .uri("/analyze_video")
                    .bodyValue(Map.of(
                            "file_path", absoluteFilePath,
                            "exercise_id", exerciseId
                    ))
                    .retrieve()
                    .bodyToMono(MlAnalysisResponse.class)
                    .block();
        } catch (Exception e) {
            logger.error("Failed to connect to the Python ML Service at /analyze_video. Is the Python server running?", e);
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Machine Learning service is currently unavailable.");
        }
    }
}
