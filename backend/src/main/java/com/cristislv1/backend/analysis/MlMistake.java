package com.cristislv1.backend.analysis;

public class MlMistake {
    private String mistake;
    private String severity;

    public MlMistake() {}

    public String getMistake() {
        return mistake;
    }

    public void setMistake(String mistake) {
        this.mistake = mistake;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }
}
