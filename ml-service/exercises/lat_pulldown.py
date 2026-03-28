from typing import List, Dict, Any
from angles import calculate_3d_angle

def analyze_lat_pulldown(landmarks_per_frame: List[Any], fps: int):
    min_back_angle = 180.0
    mistakes = []
    
    bad_back_frames = 0
    asymmetry_frames = 0
    max_asymmetry = 0.0
    
    # Track Range of Motion
    max_wrist_y = 0.0 # highest Y coordinate (lowest physical point in video)
    shoulder_y_avg = 0.0
    
    # Track Visibility to ensure the camera angle isn't blocking an arm
    total_l_visibility = 0.0
    total_r_visibility = 0.0
    valid_frames = 0
    
    for landmarks in landmarks_per_frame:
        if not landmarks or len(landmarks) < 33:
            continue
            
        l_shoulder = landmarks[11]
        r_shoulder = landmarks[12]
        l_hip = landmarks[23]
        r_hip = landmarks[24]
        l_knee = landmarks[25]
        
        l_elbow = landmarks[13]
        r_elbow = landmarks[14]
        
        l_wrist = landmarks[15]
        r_wrist = landmarks[16]
        
        # Accumulate visibility for camera angle warning
        total_l_visibility += (l_shoulder.visibility + l_elbow.visibility + l_wrist.visibility) / 3.0
        total_r_visibility += (r_shoulder.visibility + r_elbow.visibility + r_wrist.visibility) / 3.0
        valid_frames += 1
        
        # 1. Back Angle (Using 3D)
        shoulder_xyz = [l_shoulder.x, l_shoulder.y, l_shoulder.z]
        hip_xyz = [l_hip.x, l_hip.y, l_hip.z]
        knee_xyz = [l_knee.x, l_knee.y, l_knee.z]
        
        back_angle = calculate_3d_angle(shoulder_xyz, hip_xyz, knee_xyz)
        if back_angle < min_back_angle:
            min_back_angle = back_angle
            
        if back_angle < 45.0:
            bad_back_frames += 1
            
        # 2. Symmetry Check (Y coordinate difference)
        current_asymmetry = abs(l_elbow.y - r_elbow.y)
        if current_asymmetry > max_asymmetry:
            max_asymmetry = current_asymmetry
            
        if current_asymmetry > 0.08:
            asymmetry_frames += 1
            
        # 3. Range of Motion Tracking
        avg_wrist_height = (l_wrist.y + r_wrist.y) / 2.0
        if avg_wrist_height > max_wrist_y:
            max_wrist_y = avg_wrist_height
            shoulder_y_avg = (l_shoulder.y + r_shoulder.y) / 2.0
            
    # Compile final score and mistakes
    score = 100
    
    # Check Camera Angle First
    if valid_frames > 0:
        avg_l_vis = total_l_visibility / valid_frames
        avg_r_vis = total_r_visibility / valid_frames
        
        if avg_l_vis < 0.6 or avg_r_vis < 0.6:
            mistakes.append({"mistake": "Video angle is poor. Please record directly from the front or back so both arms are clearly visible.", "severity": "high"})
            score -= 40
            
    time_threshold = fps * 1.5
    
    if bad_back_frames > time_threshold:
        # Proportional Scoring: 0.5 points off per 1 degree beyond the 45 degree threshold
        degrees_off = 45.0 - min_back_angle
        penalty = min(25, int(degrees_off * 0.5)) # Cap at 25 points
        penalty = max(5, penalty) # Minimum 5 points if triggered
        
        mistakes.append({"mistake": f"Leaning too far back. Keep torso upright.", "severity": "high" if penalty > 15 else "medium"})
        score -= penalty
        
    if asymmetry_frames > time_threshold:
        # Proportional Scoring: 2 points off per 1% height disparity beyond the 8% threshold
        missed_by = max_asymmetry - 0.08
        penalty = min(20, int(missed_by * 200)) # e.g. 0.05 missed = 10 points
        penalty = max(5, penalty)
        
        mistakes.append({"mistake": "Asymmetrical pull. Ensure both elbows pull down evenly at the same time.", "severity": "high" if penalty > 15 else "medium"})
        score -= penalty
        
    torso_length = (landmarks[23].y + landmarks[24].y)/2.0 - shoulder_y_avg
    if torso_length <= 0:
        torso_length = 0.1 
        
    delta = max_wrist_y - shoulder_y_avg
    normalized_delta = delta / torso_length
    
    # Proportional Scoring: Require wrists to get to at least -0.15 normalized distance
    if normalized_delta < -0.15:
        # e.g. -0.15 - (-0.30) = 0.15 missed. 1 point penalty per 0.01 missed.
        missed_by = -0.15 - normalized_delta 
        penalty = min(25, int(missed_by * 100))
        penalty = max(5, penalty)
        
        mistakes.append({"mistake": "Poor range of motion. Pull the bar down closer to your upper chest.", "severity": "high" if penalty > 15 else "medium"})
        score -= penalty

    score = max(0, score)
        
    angles_summary = {
        "min_back_angle_reached_deg": round(float(min_back_angle), 2),
        "normalized_rom_reached": round(float(normalized_delta), 2),
        "max_arm_asymmetry_detected": round(float(max_asymmetry), 3)
    }
    
    return score, mistakes, angles_summary
