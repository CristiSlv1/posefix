from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
import os

from video_processor import process_video

app = FastAPI(title="PoseFix ML Service", description="AI service for analyzing exercise posture")

# --- DTOs ---
class AnalyzeRequest(BaseModel):
    file_path: str
    exercise_id: int

class Mistake(BaseModel):
    mistake: str
    severity: str

class AnalysisResponse(BaseModel):
    score: int
    mistakes: List[Mistake]
    angles_summary: Dict[str, Any]

# --- Endpoints ---
@app.get("/health")
def health_check():
    """Simple health check for the Spring Boot backend to verify the ML service is up."""
    return {"status": "healthy", "service": "ml-service"}

@app.post("/analyze_video", response_model=AnalysisResponse)
def analyze_video(request: AnalyzeRequest):
    """
    Analyzes a video using MediaPipe BlazePose.
    """
    if not os.path.exists(request.file_path):
        raise HTTPException(status_code=404, detail=f"Video file not found at path: {request.file_path}")
    
    print(f"Received request to analyze video: {request.file_path} for exercise {request.exercise_id}")
    
    try:
        score, mistakes, angles_summary = process_video(request.file_path, request.exercise_id)
        
        # Convert mistakes to the Pydantic model
        mistake_objects = [Mistake(mistake=m["mistake"], severity=m["severity"]) for m in mistakes]
        
        return AnalysisResponse(
            score=score,
            mistakes=mistake_objects,
            angles_summary=angles_summary
        )
    except Exception as e:
        print(f"Error processing video: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    # Runs the server on port 5000 so it doesn't conflict with Java (8080)
    uvicorn.run("main:app", host="0.0.0.0", port=5000, reload=True)
