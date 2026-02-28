package com.cristislv1.backend.workout;

import jakarta.validation.constraints.NotNull;

public record CreateWorkoutRequest(
        Long exerciseId,
        String type,
        Integer durationSeconds,
        Integer sets,
        Integer reps,
        java.math.BigDecimal weightKg,
        String notes
) {}