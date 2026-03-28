package com.cristislv1.backend.analysis;

public class AnalysisResponse {
    private Integer score;
    private String mistakes;
    private String anglesSummary;

    public AnalysisResponse(Integer score, String mistakes, String anglesSummary) {
        this.score = score;
        this.mistakes = mistakes;
        this.anglesSummary = anglesSummary;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
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
}
