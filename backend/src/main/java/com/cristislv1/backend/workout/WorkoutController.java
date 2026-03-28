package com.cristislv1.backend.workout;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/workouts")
public class WorkoutController {

    private final WorkoutRepository repo;

    public WorkoutController(WorkoutRepository repo) {
        this.repo = repo;
    }

    @PostMapping
    public Map<String, Object> create(
            @org.springframework.security.core.annotation.AuthenticationPrincipal com.cristislv1.backend.auth.SupabaseAuthService.SupabaseUser principal,
            @Valid @RequestBody CreateWorkoutRequest req) {
        UUID userId = UUID.fromString(principal.id());

        Workout w = new Workout();
        w.setUserId(userId);
        w.setExerciseId(req.exerciseId());
        w.setType(req.type() == null ? "gym" : req.type());
        w.setDurationSeconds(req.durationSeconds());
        w.setSets(req.sets());
        w.setReps(req.reps());
        w.setWeightKg(req.weightKg());
        w.setNotes(req.notes());
        w.setPerformedAt(OffsetDateTime.now());
        w.setCreatedAt(OffsetDateTime.now());

        Workout saved = repo.save(w);

        return Map.of("id", saved.getId());
    }

    @GetMapping
    public List<Workout> list(
            @org.springframework.security.core.annotation.AuthenticationPrincipal com.cristislv1.backend.auth.SupabaseAuthService.SupabaseUser principal) {
        UUID userId = UUID.fromString(principal.id());
        return repo.findByUserIdOrderByPerformedAtDesc(userId);
    }

    @GetMapping("/{id}")
    public Workout getById(
            @PathVariable Long id,
            @org.springframework.security.core.annotation.AuthenticationPrincipal com.cristislv1.backend.auth.SupabaseAuthService.SupabaseUser principal) {
        UUID userId = UUID.fromString(principal.id());
        return repo.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.NOT_FOUND, "Workout not found or access denied"));
    }
}