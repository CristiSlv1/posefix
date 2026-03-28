package com.cristislv1.backend.analysis;

import java.util.List;
import java.util.Map;

public class MlAnalysisResponse {
    private int score;
    private List<MlMistake> mistakes;
    private Map<String, Object> angles_summary; // Using underscore to match Python JSON field

    public MlAnalysisResponse() {}

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public List<MlMistake> getMistakes() {
        return mistakes;
    }

    public void setMistakes(List<MlMistake> mistakes) {
        this.mistakes = mistakes;
    }

    public Map<String, Object> getAngles_summary() {
        return angles_summary;
    }

    public void setAngles_summary(Map<String, Object> angles_summary) {
        this.angles_summary = angles_summary;
    }
}
