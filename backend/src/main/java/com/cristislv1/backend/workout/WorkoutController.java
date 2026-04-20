package com.cristislv1.backend.workout;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/workouts")
public class WorkoutController {

    private final WorkoutRepository repo;
    private final WorkoutExerciseRepository exerciseRepo;

    public WorkoutController(WorkoutRepository repo, WorkoutExerciseRepository exerciseRepo) {
        this.repo = repo;
        this.exerciseRepo = exerciseRepo;
    }

    @PostMapping
    public Map<String, Object> create(
            @org.springframework.security.core.annotation.AuthenticationPrincipal com.cristislv1.backend.auth.SupabaseAuthService.SupabaseUser principal,
            @Valid @RequestBody CreateWorkoutRequest req) {
        UUID userId = UUID.fromString(principal.id());

        Workout w = new Workout();
        w.setUserId(userId);
        w.setType(req.getType() == null ? "gym" : req.getType());
        w.setDurationSeconds(req.getDurationSeconds());
        w.setNotes(req.getNotes());
        w.setPerformedAt(OffsetDateTime.now());
        w.setCreatedAt(OffsetDateTime.now());

        if (req.getExercises() != null) {
            int index = 0;
            for (CreateWorkoutExerciseRequest exReq : req.getExercises()) {
                WorkoutExercise ex = new WorkoutExercise();
                ex.setExerciseId(exReq.getExerciseId());
                ex.setSets(exReq.getSets());
                ex.setReps(exReq.getReps());
                ex.setWeightKg(exReq.getWeightKg());
                ex.setOrderIndex(index++);
                ex.setCreatedAt(OffsetDateTime.now());
                w.addExercise(ex);
            }
        }

        Workout saved = repo.save(w);

        return Map.of("id", saved.getId());
    }

    @PostMapping("/{id}/exercises")
    public Map<String, Object> addExercise(
            @PathVariable Long id,
            @org.springframework.security.core.annotation.AuthenticationPrincipal com.cristislv1.backend.auth.SupabaseAuthService.SupabaseUser principal,
            @Valid @RequestBody CreateWorkoutExerciseRequest exReq) {
        UUID userId = UUID.fromString(principal.id());

        Workout w = repo.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Workout session not found or access denied"));

        WorkoutExercise ex = new WorkoutExercise();
        ex.setExerciseId(exReq.getExerciseId());
        ex.setSets(exReq.getSets());
        ex.setReps(exReq.getReps());
        ex.setWeightKg(exReq.getWeightKg());
        ex.setOrderIndex(w.getExercises().size());
        ex.setCreatedAt(OffsetDateTime.now());

        ex.setWorkout(w);
        WorkoutExercise savedEx = exerciseRepo.save(ex);

        return Map.of("id", savedEx.getId());
    }

    @PutMapping("/{id}/exercises/{exId}")
    public WorkoutExercise updateExercise(
            @PathVariable Long id,
            @PathVariable Long exId,
            @org.springframework.security.core.annotation.AuthenticationPrincipal com.cristislv1.backend.auth.SupabaseAuthService.SupabaseUser principal,
            @Valid @RequestBody CreateWorkoutExerciseRequest exReq) {
        UUID userId = UUID.fromString(principal.id());

        WorkoutExercise ex = exerciseRepo.findByIdAndWorkoutUserId(exId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Exercise not found or access denied"));

        if (!ex.getWorkout().getId().equals(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Exercise does not belong to this workout");
        }

        ex.setSets(exReq.getSets());
        ex.setReps(exReq.getReps());
        ex.setWeightKg(exReq.getWeightKg());
        return exerciseRepo.save(ex);
    }

    @DeleteMapping("/{id}/exercises/{exId}")
    public Map<String, Object> deleteExercise(
            @PathVariable Long id,
            @PathVariable Long exId,
            @org.springframework.security.core.annotation.AuthenticationPrincipal com.cristislv1.backend.auth.SupabaseAuthService.SupabaseUser principal) {
        UUID userId = UUID.fromString(principal.id());

        WorkoutExercise ex = exerciseRepo.findByIdAndWorkoutUserId(exId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Exercise not found or access denied"));

        if (!ex.getWorkout().getId().equals(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Exercise does not belong to this workout");
        }

        exerciseRepo.delete(ex);
        return Map.of("deleted", exId);
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
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Workout not found or access denied"));
    }
}