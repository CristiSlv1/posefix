import numpy as np

def calculate_2d_angle(a, b, c):
    """
    Calculates the 2D angle between three points a, b, c (where b is the vertex).
    Points are list/array [x,y].
    Returns angle in degrees.
    """
    a = np.array(a)
    b = np.array(b)
    c = np.array(c)
    
    radians = np.arctan2(c[1]-b[1], c[0]-b[0]) - np.arctan2(a[1]-b[1], a[0]-b[0])
    angle = np.abs(radians*180.0/np.pi)
    
    if angle > 180.0:
        angle = 360 - angle
        
    return angle

def calculate_3d_angle(a, b, c):
    """
    Calculates the 3D angle between three points a, b, c.
    Points are list/array [x,y,z].
    """
    v1 = np.array(a) - np.array(b)
    v2 = np.array(c) - np.array(b)
    
    # Handle division by zero
    if np.linalg.norm(v1) == 0 or np.linalg.norm(v2) == 0:
        return 0.0
        
    cosine_angle = np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2))
    
    # Clip to avoid floating point errors causing arccos to fail
    cosine_angle = np.clip(cosine_angle, -1.0, 1.0)
    angle = np.arccos(cosine_angle)
    
    return np.degrees(angle)
