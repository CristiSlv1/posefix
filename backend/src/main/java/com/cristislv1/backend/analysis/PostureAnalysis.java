package com.cristislv1.backend.analysis;

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "posture_analyses")
public class PostureAnalysis {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "workout_exercise_id")
    private Long workoutExerciseId;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "exercise_id")
    private Long exerciseId;

    @Column(name = "model_name", nullable = false)
    private String modelName = "mediapipe_blazepose";

    @Column(name = "model_version")
    private String modelVersion;

    @Column(nullable = false)
    private Integer score;

    @Column(name = "frames_analyzed", nullable = false)
    private Integer framesAnalyzed = 0;

    @Column(name = "mistake_count", nullable = false)
    private Integer mistakeCount = 0;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb", nullable = false)
    private String mistakes = "[]";

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "angles_summary", columnDefinition = "jsonb", nullable = false)
    private String anglesSummary = "{}";

    @Column(name = "created_at", insertable = false, updatable = false)
    private OffsetDateTime createdAt;

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getWorkoutExerciseId() {
        return workoutExerciseId;
    }

    public void setWorkoutExerciseId(Long workoutExerciseId) {
        this.workoutExerciseId = workoutExerciseId;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public Long getExerciseId() {
        return exerciseId;
    }

    public void setExerciseId(Long exerciseId) {
        this.exerciseId = exerciseId;
    }

    public String getModelName() {
        return modelName;
    }

    public void setModelName(String modelName) {
        this.modelName = modelName;
    }

    public String getModelVersion() {
        return modelVersion;
    }

    public void setModelVersion(String modelVersion) {
        this.modelVersion = modelVersion;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public Integer getFramesAnalyzed() {
        return framesAnalyzed;
    }

    public void setFramesAnalyzed(Integer framesAnalyzed) {
        this.framesAnalyzed = framesAnalyzed;
    }

    public Integer getMistakeCount() {
        return mistakeCount;
    }

    public void setMistakeCount(Integer mistakeCount) {
        this.mistakeCount = mistakeCount;
    }

    public String getMistakes() {
        return mistakes;
    }

    public void setMistakes(String mistakes) {
        this.mistakes = mistakes;
    }

    public String getAnglesSummary() {
        return anglesSummary;
    }

    public void setAnglesSummary(String anglesSummary) {
        this.anglesSummary = anglesSummary;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }
}
