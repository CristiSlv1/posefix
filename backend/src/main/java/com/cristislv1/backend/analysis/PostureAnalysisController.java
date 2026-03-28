package com.cristislv1.backend.analysis;

import com.cristislv1.backend.auth.SupabaseAuthService;
import com.cristislv1.backend.storage.VideoStorageService;
import com.cristislv1.backend.workout.Workout;
import com.cristislv1.backend.workout.WorkoutRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.UUID;

@RestController
@RequestMapping("/workouts")
public class PostureAnalysisController {

    private final WorkoutRepository workoutRepo;
    private final PostureAnalysisRepository analysisRepo;
    private final VideoStorageService storageService;
    private final MlServiceClient mlClient;
    private final ObjectMapper objectMapper;

    public PostureAnalysisController(WorkoutRepository workoutRepo, PostureAnalysisRepository analysisRepo,
                                     VideoStorageService storageService, MlServiceClient mlClient, ObjectMapper objectMapper) {
        this.workoutRepo = workoutRepo;
        this.analysisRepo = analysisRepo;
        this.storageService = storageService;
        this.mlClient = mlClient;
        this.objectMapper = objectMapper;
    }

    @PostMapping("/{id}/analyze")
    public AnalysisResponse analyzeWorkout(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal SupabaseAuthService.SupabaseUser user) {

        UUID userId = UUID.fromString(user.id());

        // 1. Verify the workout belongs to the user
        Workout workout = workoutRepo.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Workout not found or access denied"));

        // 2. Check if an analysis already exists
        if (analysisRepo.findByWorkoutId(id).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Workout already analyzed");
        }

        // 3. Store video locally
        String filePath = storageService.storeVideo(id, userId, file);

        // 4. Call ML Microservice
        MlAnalysisResponse mlResponse = mlClient.analyzeVideo(filePath, workout.getExerciseId());

        // 5. Serialize JSON for the DB
        String mistakesJson;
        String anglesJson;
        try {
            mistakesJson = objectMapper.writeValueAsString(mlResponse.getMistakes());
            anglesJson = objectMapper.writeValueAsString(mlResponse.getAngles_summary());
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to parse ML response");
        }

        // 6. Save the analysis to the DB
        PostureAnalysis analysis = new PostureAnalysis();
        analysis.setWorkoutId(workout.getId());
        analysis.setUserId(userId);
        analysis.setExerciseId(workout.getExerciseId());
        analysis.setModelName("mediapipe_blazepose");
        analysis.setModelVersion("python-v1");
        analysis.setScore(mlResponse.getScore());
        
        // Calculate frames and mistake count roughly based on the ML response
        analysis.setMistakeCount(mlResponse.getMistakes() != null ? mlResponse.getMistakes().size() : 0);
        analysis.setFramesAnalyzed(0); // We can add this to MlAnalysisResponse later if Python returns it
        
        analysis.setMistakes(mistakesJson);
        analysis.setAnglesSummary(anglesJson);

        analysisRepo.save(analysis);

        // 7. Return the result format expected by mobile frontend
        return new AnalysisResponse(mlResponse.getScore(), mistakesJson, anglesJson);
    }
}
