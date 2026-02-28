package com.cristislv1.backend.workout;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.OffsetDateTime;
import java.util.UUID;
import java.math.BigDecimal;

@Getter
@Setter
@Entity
@Table(name = "workouts")
public class Workout {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "exercise_id")
    private Long exerciseId;

    @Column(nullable = false)
    private String type = "gym";

    @Column(name = "performed_at")
    private OffsetDateTime performedAt;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    private Integer sets;
    private Integer reps;

    @Column(name = "weight_kg", precision = 6, scale = 2)
    private BigDecimal weightKg;

    private String notes;

    @Column(name = "created_at")
    private OffsetDateTime createdAt;
}