package com.cristislv1.backend.workout;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface WorkoutExerciseRepository extends JpaRepository<WorkoutExercise, Long> {
    List<WorkoutExercise> findByWorkoutIdOrderByOrderIndexAsc(Long workoutId);
    Optional<WorkoutExercise> findByIdAndWorkoutUserId(Long id, UUID userId);
}
