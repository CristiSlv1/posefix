package com.cristislv1.backend.analysis;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PostureAnalysisRepository extends JpaRepository<PostureAnalysis, Long> {
    Optional<PostureAnalysis> findByWorkoutExerciseId(Long workoutExerciseId);

    List<PostureAnalysis> findByUserIdOrderByCreatedAtDesc(UUID userId);

    Optional<PostureAnalysis> findByIdAndUserId(Long id, UUID userId);
}
