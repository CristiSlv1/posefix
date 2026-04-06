package com.cristislv1.backend.workout;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import java.util.ArrayList;

public class CreateWorkoutRequest {

    @NotBlank(message = "Type must not be blank")
    private String type = "gym";

    @Min(value = 0, message = "Duration cannot be negative")
    private Integer durationSeconds;

    private String notes;

    private List<CreateWorkoutExerciseRequest> exercises = new ArrayList<>();

    public CreateWorkoutRequest() {
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

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public List<CreateWorkoutExerciseRequest> getExercises() {
        return exercises;
    }

    public void setExercises(List<CreateWorkoutExerciseRequest> exercises) {
        this.exercises = exercises;
    }
}