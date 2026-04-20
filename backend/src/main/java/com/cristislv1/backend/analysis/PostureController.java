package com.cristislv1.backend.analysis;

import com.cristislv1.backend.auth.SupabaseAuthService;
import com.cristislv1.backend.exercise.Exercise;
import com.cristislv1.backend.exercise.ExerciseRepository;
import com.cristislv1.backend.storage.VideoStorageService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/postures")
public class PostureController {

    private final PostureAnalysisRepository analysisRepo;
    private final ExerciseRepository exerciseRepo;
    private final VideoStorageService storageService;
    private final MlServiceClient mlClient;
    private final ObjectMapper objectMapper;

    public PostureController(PostureAnalysisRepository analysisRepo,
                             ExerciseRepository exerciseRepo,
                             VideoStorageService storageService,
                             MlServiceClient mlClient,
                             ObjectMapper objectMapper) {
        this.analysisRepo = analysisRepo;
        this.exerciseRepo = exerciseRepo;
        this.storageService = storageService;
        this.mlClient = mlClient;
        this.objectMapper = objectMapper;
    }

    @GetMapping
    public List<PostureAnalysisDto> list(@AuthenticationPrincipal SupabaseAuthService.SupabaseUser user) {
        UUID userId = UUID.fromString(user.id());
        List<PostureAnalysis> all = analysisRepo.findByUserIdOrderByCreatedAtDesc(userId);

        Map<Long, String> exerciseNames = exerciseRepo.findAll().stream()
                .collect(Collectors.toMap(Exercise::getId, Exercise::getName));

        return all.stream()
                .map(a -> new PostureAnalysisDto(a, exerciseNames.get(a.getExerciseId())))
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public PostureAnalysisDto get(@PathVariable Long id,
                                  @AuthenticationPrincipal SupabaseAuthService.SupabaseUser user) {
        UUID userId = UUID.fromString(user.id());
        PostureAnalysis analysis = analysisRepo.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Analysis not found"));
        String exerciseName = exerciseRepo.findById(analysis.getExerciseId()).map(Exercise::getName).orElse(null);
        return new PostureAnalysisDto(analysis, exerciseName);
    }

    @PostMapping("/analyze")
    public PostureAnalysisDto analyze(@RequestParam("exerciseId") Long exerciseId,
                                      @RequestParam("file") MultipartFile file,
                                      @AuthenticationPrincipal SupabaseAuthService.SupabaseUser user) {
        UUID userId = UUID.fromString(user.id());

        Optional<Exercise> exerciseOpt = exerciseRepo.findById(exerciseId);
        if (exerciseOpt.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Exercise not found");
        }

        String filePath = storageService.storeVideo(0L, userId, file);

        MlAnalysisResponse mlResponse = mlClient.analyzeVideo(filePath, exerciseId);

        String mistakesJson;
        String anglesJson;
        try {
            mistakesJson = objectMapper.writeValueAsString(mlResponse.getMistakes());
            anglesJson = objectMapper.writeValueAsString(mlResponse.getAngles_summary());
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to parse ML response");
        }

        PostureAnalysis analysis = new PostureAnalysis();
        analysis.setWorkoutExerciseId(null);
        analysis.setUserId(userId);
        analysis.setExerciseId(exerciseId);
        analysis.setModelName("mediapipe_blazepose");
        analysis.setModelVersion("python-v1");
        analysis.setScore(mlResponse.getScore());
        analysis.setMistakeCount(mlResponse.getMistakes() != null ? mlResponse.getMistakes().size() : 0);
        analysis.setFramesAnalyzed(0);
        analysis.setMistakes(mistakesJson);
        analysis.setAnglesSummary(anglesJson);

        PostureAnalysis saved = analysisRepo.save(analysis);
        return new PostureAnalysisDto(saved, exerciseOpt.get().getName());
    }
}
