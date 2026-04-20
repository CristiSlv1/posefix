package com.cristislv1.backend.analysis;

import java.time.OffsetDateTime;

public class PostureAnalysisDto {
    private Long id;
    private Long exerciseId;
    private String exerciseName;
    private Integer score;
    private Integer mistakeCount;
    private Integer framesAnalyzed;
    private String mistakes;
    private String anglesSummary;
    private OffsetDateTime createdAt;

    public PostureAnalysisDto() {}

    public PostureAnalysisDto(PostureAnalysis a, String exerciseName) {
        this.id = a.getId();
        this.exerciseId = a.getExerciseId();
        this.exerciseName = exerciseName;
        this.score = a.getScore();
        this.mistakeCount = a.getMistakeCount();
        this.framesAnalyzed = a.getFramesAnalyzed();
        this.mistakes = a.getMistakes();
        this.anglesSummary = a.getAnglesSummary();
        this.createdAt = a.getCreatedAt();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getExerciseId() { return exerciseId; }
    public void setExerciseId(Long exerciseId) { this.exerciseId = exerciseId; }

    public String getExerciseName() { return exerciseName; }
    public void setExerciseName(String exerciseName) { this.exerciseName = exerciseName; }

    public Integer getScore() { return score; }
    public void setScore(Integer score) { this.score = score; }

    public Integer getMistakeCount() { return mistakeCount; }
    public void setMistakeCount(Integer mistakeCount) { this.mistakeCount = mistakeCount; }

    public Integer getFramesAnalyzed() { return framesAnalyzed; }
    public void setFramesAnalyzed(Integer framesAnalyzed) { this.framesAnalyzed = framesAnalyzed; }

    public String getMistakes() { return mistakes; }
    public void setMistakes(String mistakes) { this.mistakes = mistakes; }

    public String getAnglesSummary() { return anglesSummary; }
    public void setAnglesSummary(String anglesSummary) { this.anglesSummary = anglesSummary; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
