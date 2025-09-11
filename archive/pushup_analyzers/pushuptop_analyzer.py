import cv2
import mediapipe as mp
import numpy as np
import os
import sys
import argparse

class PushUpTopAnalyzer:
    def __init__(self):
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_pose = mp.solutions.pose
        
        # Drawing style
        self.drawing_spec = self.mp_drawing.DrawingSpec(thickness=2, circle_radius=2)
        
        # Landmarks for both shoulders, elbows, and wrists
        self.landmark_list = [
            self.mp_pose.PoseLandmark.LEFT_SHOULDER,
            self.mp_pose.PoseLandmark.RIGHT_SHOULDER,
            self.mp_pose.PoseLandmark.LEFT_ELBOW,
            self.mp_pose.PoseLandmark.RIGHT_ELBOW,
            self.mp_pose.PoseLandmark.LEFT_WRIST,
            self.mp_pose.PoseLandmark.RIGHT_WRIST
        ]
        
        # Connections for arms (shoulder-elbow-wrist)
        self.custom_connections = frozenset([
            (self.mp_pose.PoseLandmark.LEFT_SHOULDER, self.mp_pose.PoseLandmark.LEFT_ELBOW),
            (self.mp_pose.PoseLandmark.LEFT_ELBOW, self.mp_pose.PoseLandmark.LEFT_WRIST),
            (self.mp_pose.PoseLandmark.RIGHT_SHOULDER, self.mp_pose.PoseLandmark.RIGHT_ELBOW),
            (self.mp_pose.PoseLandmark.RIGHT_ELBOW, self.mp_pose.PoseLandmark.RIGHT_WRIST)
        ])
        
        self.pose = self.mp_pose.Pose(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5)

    def calculate_angle(self, a, b, c):
        a = np.array(a)
        b = np.array(b)
        c = np.array(c)
        radians = np.arctan2(c[1]-b[1], c[0]-b[0]) - np.arctan2(a[1]-b[1], a[0]-b[0])
        angle = np.abs(radians*180.0/np.pi)
        if angle > 180.0:
            angle = 360-angle
        return angle

    def process_video(self, input_path, output_path, preview=False):
        try:
            cap = cv2.VideoCapture(input_path)
            if not cap.isOpened():
                print("Error: Could not open video file")
                return
            width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            fps = int(cap.get(cv2.CAP_PROP_FPS))
            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            out = cv2.VideoWriter(output_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, (width, height))
            frame_count = 0
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                image.flags.writeable = False
                results = self.pose.process(image)
                image.flags.writeable = True
                image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
                try:
                    landmarks = results.pose_landmarks.landmark
                    h, w, c = image.shape
                    # Get coordinates for all relevant landmarks
                    coords = {}
                    for lm in self.landmark_list:
                        coords[lm] = (int(landmarks[lm.value].x * w), int(landmarks[lm.value].y * h))
                    # Draw landmarks
                    for point in coords.values():
                        cv2.circle(image, point, 6, (255, 255, 255), -1)
                    # Draw connections
                    for conn in self.custom_connections:
                        pt1, pt2 = coords[conn[0]], coords[conn[1]]
                        cv2.line(image, pt1, pt2, (0, 255, 255), 3)
                    # Calculate and display elbow angles
                    left_angle = self.calculate_angle(
                        coords[self.mp_pose.PoseLandmark.LEFT_SHOULDER],
                        coords[self.mp_pose.PoseLandmark.LEFT_ELBOW],
                        coords[self.mp_pose.PoseLandmark.LEFT_WRIST]
                    )
                    right_angle = self.calculate_angle(
                        coords[self.mp_pose.PoseLandmark.RIGHT_SHOULDER],
                        coords[self.mp_pose.PoseLandmark.RIGHT_ELBOW],
                        coords[self.mp_pose.PoseLandmark.RIGHT_WRIST]
                    )
                    cv2.putText(image, f"L-Elbow: {int(left_angle)}", 
                        (coords[self.mp_pose.PoseLandmark.LEFT_ELBOW][0]-40, coords[self.mp_pose.PoseLandmark.LEFT_ELBOW][1]-20),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,0), 2)
                    cv2.putText(image, f"R-Elbow: {int(right_angle)}", 
                        (coords[self.mp_pose.PoseLandmark.RIGHT_ELBOW][0]-40, coords[self.mp_pose.PoseLandmark.RIGHT_ELBOW][1]-20),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,0), 2)
                except Exception as e:
                    print(f"Frame {frame_count} processing error: {e}")
                    image = frame
                out.write(image)
                frame_count += 1
                if preview:
                    cv2.imshow('Preview', image)
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
    parser = argparse.ArgumentParser(description='Analyze push-up form from top-down view.')
    parser.add_argument('--input', type=str, required=True, help='Input video path')
    parser.add_argument('--output', type=str, default="analyzed_pushup.mp4", help='Output video path')
    parser.add_argument('--preview', action='store_true', help='Enable preview window')
    args = parser.parse_args()

    analyzer = PushUpTopAnalyzer()
    analyzer.process_video(args.input, args.output, preview=args.preview)
