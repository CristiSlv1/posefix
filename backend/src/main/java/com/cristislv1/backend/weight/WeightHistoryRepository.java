package com.cristislv1.backend.weight;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface WeightHistoryRepository extends JpaRepository<WeightHistory, Long> {
    Optional<WeightHistory> findByUserIdAndMeasuredOn(UUID userId, LocalDate date);

    List<WeightHistory> findTop30ByUserIdOrderByMeasuredOnDesc(UUID userId);
}
