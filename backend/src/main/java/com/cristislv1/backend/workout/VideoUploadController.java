package com.cristislv1.backend.workout;

import com.cristislv1.backend.auth.SupabaseAuthService;
import com.cristislv1.backend.storage.VideoStorageService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/workouts")
public class VideoUploadController {

    private final WorkoutRepository workoutRepo;
    private final VideoStorageService storageService;

    public VideoUploadController(WorkoutRepository workoutRepo, VideoStorageService storageService) {
        this.workoutRepo = workoutRepo;
        this.storageService = storageService;
    }

    @PostMapping("/{id}/upload-video")
    public Map<String, String> handleVideoUpload(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal SupabaseAuthService.SupabaseUser user) {

        UUID userId = UUID.fromString(user.id());

        // Ensure the workout belongs to the user
        workoutRepo.findByIdAndUserId(id, userId)
                .orElseThrow(
                        () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Workout not found or access denied"));

        String filePath = storageService.storeVideo(id, userId, file);

        return Map.of(
                "message", "File uploaded successfully",
                "path", filePath);
    }
}
