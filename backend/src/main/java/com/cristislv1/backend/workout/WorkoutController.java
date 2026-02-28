package com.cristislv1.backend.workout;

import com.cristislv1.backend.auth.SupabaseAuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/workouts")
public class WorkoutController {

    private final WorkoutRepository repo;
    private final SupabaseAuthService auth;

    public WorkoutController(WorkoutRepository repo, SupabaseAuthService auth) {
        this.repo = repo;
        this.auth = auth;
    }

    private UUID requireUserId(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing Bearer token");
        }
        var token = authorization.substring("Bearer ".length());
        var user = auth.getUser(token).block();
        if (user == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
        return UUID.fromString(user.id());
    }

    @PostMapping
    public Map<String, Object> create(
            @RequestHeader("Authorization") String authorization,
            @Valid @RequestBody CreateWorkoutRequest req
    ) {
        UUID userId = requireUserId(authorization);

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
    public List<Workout> list(@RequestHeader("Authorization") String authorization) {
        UUID userId = requireUserId(authorization);
        return repo.findByUserIdOrderByPerformedAtDesc(userId);
    }
}