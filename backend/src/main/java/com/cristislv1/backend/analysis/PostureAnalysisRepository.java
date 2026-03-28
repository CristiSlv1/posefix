package com.cristislv1.backend.analysis;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface PostureAnalysisRepository extends JpaRepository<PostureAnalysis, Long> {
    Optional<PostureAnalysis> findByWorkoutId(Long workoutId);
}
