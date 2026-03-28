import cv2
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from exercises.lat_pulldown import analyze_lat_pulldown
import os

def process_video(file_path: str, exercise_id: int):
    cap = cv2.VideoCapture(file_path)
    if not cap.isOpened():
        raise Exception(f"Failed to open video at {file_path}")
        
    fps = int(cap.get(cv2.CAP_PROP_FPS))
    if fps <= 0:
        fps = 30 # Safe default
        
    landmarks_per_frame = []
    
    # Locate the .task model file downloaded earlier
    model_path = os.path.join(os.path.dirname(__file__), 'pose_landmarker.task')
    
    # Initialize the modern MediaPipe Tasks API
    base_options = python.BaseOptions(model_asset_path=model_path)
    options = vision.PoseLandmarkerOptions(
        base_options=base_options,
        running_mode=vision.RunningMode.VIDEO)
        
    with vision.PoseLandmarker.create_from_options(options) as landmarker:
        while cap.isOpened():
            success, frame = cap.read()
            if not success:
                break
                
            image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=image_rgb)
            
            # MediaPipe tasks VIDEO mode requires timestamps
            timestamp_ms = int(cap.get(cv2.CAP_PROP_POS_MSEC))
            if timestamp_ms < 0:
                timestamp_ms = 0
                
            # Perform detection
            result = landmarker.detect_for_video(mp_image, timestamp_ms)
            
            # result.pose_landmarks returns a list of poses (1 list item per detected person)
            if result.pose_landmarks and len(result.pose_landmarks) > 0:
                # We extract the first person detected
                landmarks_per_frame.append(result.pose_landmarks[0])
                
    cap.release()
    
    # Route to the correct exercise logic
    if exercise_id == 1:
        score, mistakes, angles_summary = analyze_lat_pulldown(landmarks_per_frame, fps)
        return score, mistakes, angles_summary
    else:
        return 100, [], {"info": f"No heuristics defined yet for exercise_id={exercise_id}"}
