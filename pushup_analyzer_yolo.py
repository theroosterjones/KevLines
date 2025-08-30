import cv2
import numpy as np
import os
import sys
import argparse
from ultralytics import YOLO

class PushUpTopAnalyzerYOLO:
    def __init__(self):
        # Load YOLOv8 pose model
        self.model = YOLO('yolov8n-pose.pt')  # or yolov8s-pose.pt for better accuracy
        
        # Keypoint indices for arms (YOLO pose keypoints)
        self.keypoint_indices = {
            'left_shoulder': 5,
            'right_shoulder': 6,
            'left_elbow': 7,
            'right_elbow': 8,
            'left_wrist': 9,
            'right_wrist': 10
        }
        
        # Confidence threshold
        self.conf_threshold = 0.3

    def calculate_angle(self, a, b, c):
        """Calculate angle between three points"""
        a = np.array(a)
        b = np.array(b)
        c = np.array(c)
        radians = np.arctan2(c[1]-b[1], c[0]-b[0]) - np.arctan2(a[1]-b[1], a[0]-b[0])
        angle = np.abs(radians*180.0/np.pi)
        if angle > 180.0:
            angle = 360-angle
        return angle

    def get_keypoint_coords(self, keypoints, idx):
        """Extract coordinates for a specific keypoint"""
        if idx < len(keypoints) and keypoints[idx][2] > self.conf_threshold:
            return (int(keypoints[idx][0]), int(keypoints[idx][1]))
        return None

    def process_video(self, input_path, output_path, preview=False):
        try:
            cap = cv2.VideoCapture(input_path)
            if not cap.isOpened():
                print("Error: Could not open video file")
                return
                
            width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            fps = int(cap.get(cv2.CAP_PROP_FPS))
            
            out = cv2.VideoWriter(output_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, (width, height))
            frame_count = 0
            
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                    
                # Run YOLO pose detection
                results = self.model(frame, verbose=False)
                
                # Process results
                if len(results) > 0 and len(results[0].keypoints) > 0:
                    keypoints = results[0].keypoints.data[0].cpu().numpy()
                    
                    # Get coordinates for relevant keypoints
                    coords = {}
                    for name, idx in self.keypoint_indices.items():
                        coord = self.get_keypoint_coords(keypoints, idx)
                        if coord:
                            coords[name] = coord
                    
                    # Draw landmarks and connections if we have enough points
                    if len(coords) >= 4:  # At least shoulders and elbows
                        # Draw landmarks
                        for coord in coords.values():
                            cv2.circle(frame, coord, 6, (255, 255, 255), -1)
                        
                        # Draw connections
                        connections = [
                            ('left_shoulder', 'left_elbow'),
                            ('left_elbow', 'left_wrist'),
                            ('right_shoulder', 'right_elbow'),
                            ('right_elbow', 'right_wrist')
                        ]
                        
                        for start, end in connections:
                            if start in coords and end in coords:
                                cv2.line(frame, coords[start], coords[end], (0, 255, 255), 3)
                        
                        # Calculate and display elbow angles
                        if all(k in coords for k in ['left_shoulder', 'left_elbow', 'left_wrist']):
                            left_angle = self.calculate_angle(
                                coords['left_shoulder'],
                                coords['left_elbow'],
                                coords['left_wrist']
                            )
                            cv2.putText(frame, f"L-Elbow: {int(left_angle)}", 
                                (coords['left_elbow'][0]-40, coords['left_elbow'][1]-20),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,0), 2)
                        
                        if all(k in coords for k in ['right_shoulder', 'right_elbow', 'right_wrist']):
                            right_angle = self.calculate_angle(
                                coords['right_shoulder'],
                                coords['right_elbow'],
                                coords['right_wrist']
                            )
                            cv2.putText(frame, f"R-Elbow: {int(right_angle)}", 
                                (coords['right_elbow'][0]-40, coords['right_elbow'][1]-20),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,0), 2)
                
                out.write(frame)
                frame_count += 1
                
                if preview:
                    cv2.imshow('Preview', frame)
                    if cv2.waitKey(1) & 0xFF == ord('q'):
                        print("\nProcessing interrupted by user")
                        break
                        
            cap.release()
            out.release()
            cv2.destroyAllWindows()
            print(f"\nSuccess! Video saved to: {output_path}")
            
        except Exception as e:
            print(f"\nError during video processing: {e}")
            sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Analyze push-up form from top-down view using YOLOv8 Pose.')
    parser.add_argument('--input', type=str, required=True, help='Input video path')
    parser.add_argument('--output', type=str, default="analyzed_pushup_yolo.mp4", help='Output video path')
    parser.add_argument('--preview', action='store_true', help='Enable preview window')
    args = parser.parse_args()

    analyzer = PushUpTopAnalyzerYOLO()
    analyzer.process_video(args.input, args.output, preview=args.preview) 