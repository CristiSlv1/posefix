package com.cristislv1.backend.workout;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class CreateWorkoutRequest {

        @NotNull(message = "Exercise ID is required")
        private Long exerciseId;

        @NotBlank(message = "Type must not be blank")
        private String type = "gym";

        @Min(value = 0, message = "Duration cannot be negative")
        private Integer durationSeconds;

        @NotNull(message = "Sets are required")
        @Min(value = 1, message = "Sets must be at least 1")
        private Integer sets;

        @NotNull(message = "Reps are required")
        @Min(value = 1, message = "Reps must be at least 1")
        private Integer reps;

        @DecimalMin(value = "0.0", message = "Weight cannot be negative")
        private BigDecimal weightKg;

        private String notes;

        public CreateWorkoutRequest() {
        }

        public CreateWorkoutRequest(Long exerciseId, String type, Integer durationSeconds, Integer sets, Integer reps,
                        BigDecimal weightKg, String notes) {
                this.exerciseId = exerciseId;
                this.type = type;
                this.durationSeconds = durationSeconds;
                this.sets = sets;
                this.reps = reps;
                this.weightKg = weightKg;
                this.notes = notes;
        }

        public Long exerciseId() {
                return exerciseId;
        }

        public String type() {
                return type;
        }

        public Integer durationSeconds() {
                return durationSeconds;
        }

        public Integer sets() {
                return sets;
        }

        public Integer reps() {
                return reps;
        }

        public BigDecimal weightKg() {
                return weightKg;
        }

        public String notes() {
                return notes;
        }

        public Long getExerciseId() {
                return exerciseId;
        }

        public void setExerciseId(Long exerciseId) {
                this.exerciseId = exerciseId;
        }

        public String getType() {
                return type;
        }

        public void setType(String type) {
                this.type = type;
        }

        public Integer getDurationSeconds() {
                return durationSeconds;
        }

        public void setDurationSeconds(Integer durationSeconds) {
                this.durationSeconds = durationSeconds;
        }

        public Integer getSets() {
                return sets;
        }

        public void setSets(Integer sets) {
                this.sets = sets;
        }

        public Integer getReps() {
                return reps;
        }

        public void setReps(Integer reps) {
                this.reps = reps;
        }

        public BigDecimal getWeightKg() {
                return weightKg;
        }

        public void setWeightKg(BigDecimal weightKg) {
                this.weightKg = weightKg;
        }

        public String getNotes() {
                return notes;
        }

        public void setNotes(String notes) {
                this.notes = notes;
        }
}