import pytest
import numpy as np
from pose_analyzer import PoseAnalyzer

def test_pose_analyzer_initialization():
    """Test if PoseAnalyzer initializes correctly"""
    analyzer = PoseAnalyzer()
    assert analyzer is not None
    assert analyzer.pose is not None

def test_calculate_angle():
    """Test the angle calculation method"""
    analyzer = PoseAnalyzer()
    
    # Test right angle (90 degrees)
    point_a = [0, 0]
    point_b = [0, 1]
    point_c = [1, 1]
    angle = analyzer.calculate_angle(point_a, point_b, point_c)
    assert abs(angle - 90) < 1  # Allow for small floating point differences
    
    # Test straight angle (180 degrees)
    point_a = [0, 0]
    point_b = [1, 0]
    point_c = [2, 0]
    angle = analyzer.calculate_angle(point_a, point_b, point_c)
    assert abs(angle - 180) < 1
    
    # Test acute angle (45 degrees)
    point_a = [0, 0]
    point_b = [0, 0]
    point_c = [1, 1]
    angle = analyzer.calculate_angle(point_a, point_b, point_c)
    assert abs(angle - 45) < 1

def test_video_capture_setup(tmp_path):
    """Test if video capture setup works with a mock video file"""
    import cv2
    
    # Create a temporary video file
    video_path = str(tmp_path / "test_video.mp4")
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(video_path, fourcc, 20.0, (640,480))
    
    # Write a few frames
    for _ in range(10):
        frame = np.zeros((480,640,3), dtype=np.uint8)
        out.write(frame)
    out.release()
    
    # Test if video can be opened
    analyzer = PoseAnalyzer()
    cap = cv2.VideoCapture(video_path)
    assert cap.isOpened()
    cap.release() 