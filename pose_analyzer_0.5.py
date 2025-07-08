import cv2
import mediapipe as mp
import numpy as np

class PoseAnalyzer:
    def __init__(self):
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_pose = mp.solutions.pose
        
        # Customize drawing style
        self.drawing_spec = self.mp_drawing.DrawingSpec(thickness=2, circle_radius=2)
        
        # Define which landmarks to show (left side only)
        self.landmark_list = [
            self.mp_pose.PoseLandmark.LEFT_SHOULDER,
            self.mp_pose.PoseLandmark.LEFT_ELBOW,
            self.mp_pose.PoseLandmark.LEFT_WRIST,
            self.mp_pose.PoseLandmark.LEFT_HIP
        ]
        
        # Define connections between landmarks (white skeleton lines, left side only)
        self.custom_connections = frozenset([
            (self.mp_pose.PoseLandmark.LEFT_SHOULDER, self.mp_pose.PoseLandmark.LEFT_HIP)
        ])
        
        self.pose = self.mp_pose.Pose(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5)

    def calculate_angle(self, a, b, c):
        """
        Calculate the angle between three points.
        Args:
            a: first point [x, y]
            b: mid point [x, y] (the joint)
            c: end point [x, y]
        Returns:
            angle in degrees
        """
        a = np.array(a)
        b = np.array(b)
        c = np.array(c)
        
        radians = np.arctan2(c[1]-b[1], c[0]-b[0]) - np.arctan2(a[1]-b[1], a[0]-b[0])
        angle = np.abs(radians*180.0/np.pi)
        
        if angle > 180.0:
            angle = 360-angle
            
        return angle

    def extend_line_to_frame(self, point1, point2, frame_width, frame_height):
        """
        Extend a line passing through two points to the frame boundaries.
        Args:
            point1, point2: Points the line passes through [(x, y), (x, y)]
            frame_width, frame_height: Dimensions of the frame
        Returns:
            Two points at frame boundaries
        """
        x1, y1 = point1
        x2, y2 = point2
        
        if x2 - x1 == 0:  # Vertical line
            return [(x1, 0), (x1, frame_height)]
            
        # Calculate line equation y = mx + b
        m = (y2 - y1) / (x2 - x1)
        b = y1 - m * x1
        
        # Find intersections with frame boundaries
        # Left boundary (x = 0)
        left_y = b
        # Right boundary (x = width)
        right_y = m * frame_width + b
        # Top boundary (y = 0)
        top_x = -b / m if m != 0 else x1
        # Bottom boundary (y = height)
        bottom_x = (frame_height - b) / m if m != 0 else x1
        
        # Collect all valid intersection points
        points = []
        if 0 <= left_y <= frame_height:
            points.append((0, int(left_y)))
        if 0 <= right_y <= frame_height:
            points.append((frame_width, int(right_y)))
        if 0 <= top_x <= frame_width:
            points.append((int(top_x), 0))
        if 0 <= bottom_x <= frame_width:
            points.append((int(bottom_x), frame_height))
            
        # Sort points by x coordinate to ensure consistent line direction
        points.sort(key=lambda p: p[0])
        return points[:2]  # Return first two valid points

    def process_video(self, video_path):
        cap = cv2.VideoCapture(video_path)
        
        # Get video properties
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        
        # Create video writer
        output_path = 'analyzed_latpulldown.mp4'
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            # Recolor image to RGB
            image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            image.flags.writeable = False
          
            # Make detection
            results = self.pose.process(image)
        
            # Recolor back to BGR
            image.flags.writeable = True
            image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
            
            try:
                landmarks = results.pose_landmarks.landmark
                
                # Get coordinates for left arm angle
                shoulder = [landmarks[self.mp_pose.PoseLandmark.LEFT_SHOULDER.value].x,
                          landmarks[self.mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
                elbow = [landmarks[self.mp_pose.PoseLandmark.LEFT_ELBOW.value].x,
                        landmarks[self.mp_pose.PoseLandmark.LEFT_ELBOW.value].y]
                wrist = [landmarks[self.mp_pose.PoseLandmark.LEFT_WRIST.value].x,
                        landmarks[self.mp_pose.PoseLandmark.LEFT_WRIST.value].y]
                
                # Get spine landmarks
                hip = [landmarks[self.mp_pose.PoseLandmark.LEFT_HIP.value].x,
                      landmarks[self.mp_pose.PoseLandmark.LEFT_HIP.value].y]
                
                # Calculate angles
                elbow_angle = self.calculate_angle(shoulder, elbow, wrist)
                shoulder_angle = self.calculate_angle(hip, shoulder, elbow)
                
                # Visualize
                h, w, c = image.shape
                
                # Draw white skeleton first
                # Draw landmarks
                for landmark in self.landmark_list:
                    x = int(landmarks[landmark.value].x * w)
                    y = int(landmarks[landmark.value].y * h)
                    cv2.circle(image, (x, y), 5, (255, 255, 255), -1)
                
                # Draw connections
                for connection in self.custom_connections:
                    start_landmark = landmarks[connection[0].value]
                    end_landmark = landmarks[connection[1].value]
                    
                    start_point = (int(start_landmark.x * w), int(start_landmark.y * h))
                    end_point = (int(end_landmark.x * w), int(end_landmark.y * h))
                    
                    cv2.line(image, start_point, end_point, (255, 255, 255), 2)
                
                # Convert coordinates to pixel values for visualization
                shoulder_px = (int(shoulder[0] * w), int(shoulder[1] * h))
                elbow_px = (int(elbow[0] * w), int(elbow[1] * h))
                wrist_px = (int(wrist[0] * w), int(wrist[1] * h))
                hip_px = (int(hip[0] * w), int(hip[1] * h))
                
                # Calculate and draw extended forearm line
                extended_line_points = self.extend_line_to_frame(wrist_px, elbow_px, w, h)
                cv2.line(image, extended_line_points[0], extended_line_points[1], (0, 255, 255), 1)  # Thin yellow line
                
                # Draw angle visualization lines
                cv2.line(image, hip_px, shoulder_px, (0, 255, 255), 2)  # Yellow line for torso
                cv2.line(image, shoulder_px, elbow_px, (255, 255, 0), 3)  # Bright yellow for upper arm
                cv2.line(image, elbow_px, wrist_px, (255, 255, 0), 3)
                
                # Draw dots at joints
                cv2.circle(image, elbow_px, 10, (0, 0, 255), -1)
                cv2.circle(image, shoulder_px, 10, (0, 0, 255), -1)
                
                # Put angle text
                cv2.putText(image, f"Elbow: {int(elbow_angle)}", 
                           (elbow_px[0]-50, elbow_px[1]+50),
                           cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
                           
                cv2.putText(image, f"Shoulder: {int(shoulder_angle)}", 
                           (shoulder_px[0]-50, shoulder_px[1]-30),
                           cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
                
            except:
                pass
            
            # Show image
            cv2.imshow('Pose Analysis', image)
            out.write(image)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
                
        cap.release()
        out.release()
        cv2.destroyAllWindows()
        print(f"\nVideo saved as: {output_path}")

if __name__ == "__main__":
    analyzer = PoseAnalyzer()
    video_path = "/Users/kevinrooster/Downloads/latpulldown.mov"  # Direct path to video
    analyzer.process_video(video_path) 