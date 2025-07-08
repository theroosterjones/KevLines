import cv2
import mediapipe as mp
import numpy as np
import os
import sys
import subprocess
import math
from moviepy.editor import VideoFileClip
import argparse

class RowAnalyzer:
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
            self.mp_pose.PoseLandmark.LEFT_HIP,
            self.mp_pose.PoseLandmark.RIGHT_SHOULDER,  # For back line
            self.mp_pose.PoseLandmark.LEFT_EAR,  # For back alignment
            self.mp_pose.PoseLandmark.RIGHT_EAR  # For back alignment
        ]
        
        # Define connections between landmarks (white skeleton lines, left side only)
        self.custom_connections = frozenset([
            (self.mp_pose.PoseLandmark.LEFT_SHOULDER, self.mp_pose.PoseLandmark.RIGHT_SHOULDER)  # Back line
        ])
        
        self.pose = self.mp_pose.Pose(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5)

    def calculate_spine_landmarks(self, left_shoulder, right_shoulder, hip):
        """
        Calculate estimated spine landmarks based on shoulder positions.
        Args:
            left_shoulder: left shoulder coordinates [x, y]
            right_shoulder: right shoulder coordinates [x, y]
            hip: hip coordinates [x, y]
        Returns:
            spine_landmarks: list of estimated spine points [x, y]
        """
        # Calculate midpoint between shoulders
        shoulder_midpoint = [(left_shoulder[0] + right_shoulder[0]) / 2,
                           (left_shoulder[1] + right_shoulder[1]) / 2]
        
        # Calculate spine direction (from shoulders to hip)
        spine_direction = [hip[0] - shoulder_midpoint[0], hip[1] - shoulder_midpoint[1]]
        spine_length = np.sqrt(spine_direction[0]**2 + spine_direction[1]**2)
        
        # Normalize direction
        if spine_length > 0:
            spine_direction = [spine_direction[0] / spine_length, spine_direction[1] / spine_length]
        
        # Create spine landmarks at different heights
        spine_landmarks = []
        
        # Upper spine (near shoulders)
        upper_spine = [shoulder_midpoint[0] + spine_direction[0] * spine_length * 0.1,
                      shoulder_midpoint[1] + spine_direction[1] * spine_length * 0.1]
        spine_landmarks.append(upper_spine)
        
        # Mid spine
        mid_spine = [shoulder_midpoint[0] + spine_direction[0] * spine_length * 0.5,
                    shoulder_midpoint[1] + spine_direction[1] * spine_length * 0.5]
        spine_landmarks.append(mid_spine)
        
        # Lower spine (near hip)
        lower_spine = [shoulder_midpoint[0] + spine_direction[0] * spine_length * 0.9,
                      shoulder_midpoint[1] + spine_direction[1] * spine_length * 0.9]
        spine_landmarks.append(lower_spine)
        
        return spine_landmarks

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

    def extend_line_to_frame(self, point1, point2, width, height):
        # Convert points to numpy arrays
        p1 = np.array(point1)
        p2 = np.array(point2)
        
        # Calculate direction vector
        direction = p2 - p1
        direction = direction / np.linalg.norm(direction)
        
        # Calculate distances to each edge
        distances = []
        points = []
        
        # Top edge (y = 0)
        if direction[1] != 0:
            t = -p1[1] / direction[1]
            if t > 0:
                x = p1[0] + t * direction[0]
                if 0 <= x <= width:
                    distances.append(t)
                    points.append((int(x), 0))
        
        # Bottom edge (y = height)
        if direction[1] != 0:
            t = (height - p1[1]) / direction[1]
            if t > 0:
                x = p1[0] + t * direction[0]
                if 0 <= x <= width:
                    distances.append(t)
                    points.append((int(x), height))
        
        # Left edge (x = 0)
        if direction[0] != 0:
            t = -p1[0] / direction[0]
            if t > 0:
                y = p1[1] + t * direction[1]
                if 0 <= y <= height:
                    distances.append(t)
                    points.append((0, int(y)))
        
        # Right edge (x = width)
        if direction[0] != 0:
            t = (width - p1[0]) / direction[0]
            if t > 0:
                y = p1[1] + t * direction[1]
                if 0 <= y <= height:
                    distances.append(t)
                    points.append((width, int(y)))
        
        if not points:
            return point1, point2
        
        # Find the furthest point
        max_dist_idx = np.argmax(distances)
        furthest_point = points[max_dist_idx]
        
        # Calculate the opposite direction to extend the line in the other direction
        opposite_direction = -direction
        opposite_distances = []
        opposite_points = []
        
        # Top edge (y = 0)
        if opposite_direction[1] != 0:
            t = -p2[1] / opposite_direction[1]
            if t > 0:
                x = p2[0] + t * opposite_direction[0]
                if 0 <= x <= width:
                    opposite_distances.append(t)
                    opposite_points.append((int(x), 0))
        
        # Bottom edge (y = height)
        if opposite_direction[1] != 0:
            t = (height - p2[1]) / opposite_direction[1]
            if t > 0:
                x = p2[0] + t * opposite_direction[0]
                if 0 <= x <= width:
                    opposite_distances.append(t)
                    opposite_points.append((int(x), height))
        
        # Left edge (x = 0)
        if opposite_direction[0] != 0:
            t = -p2[0] / opposite_direction[0]
            if t > 0:
                y = p2[1] + t * opposite_direction[1]
                if 0 <= y <= height:
                    opposite_distances.append(t)
                    opposite_points.append((0, int(y)))
        
        # Right edge (x = width)
        if opposite_direction[0] != 0:
            t = (width - p2[0]) / opposite_direction[0]
            if t > 0:
                y = p2[1] + t * opposite_direction[1]
                if 0 <= y <= height:
                    opposite_distances.append(t)
                    opposite_points.append((width, int(y)))
        
        if not opposite_points:
            return furthest_point, point2
        
        # Find the furthest point in the opposite direction
        max_opposite_dist_idx = np.argmax(opposite_distances)
        furthest_opposite_point = opposite_points[max_opposite_dist_idx]
        
        return furthest_point, furthest_opposite_point

    def compress_to_mp4(self, input_path, output_path):
        """Compress AVI to MP4 using moviepy"""
        try:
            # Check if input file exists
            if not os.path.exists(input_path):
                print(f"Error: Input file {input_path} does not exist")
                return False
            
            print("\nCompressing video to MP4...")
            
            # Get original file size
            input_size = os.path.getsize(input_path) / (1024*1024)  # MB
            
            # Load video
            video = VideoFileClip(input_path)
            
            # Write compressed video
            video.write_videofile(
                output_path,
                codec='libx264',
                audio_codec='aac',
                bitrate='2000k',
                fps=video.fps,
                threads=4,
                preset='medium'
            )
            
            # Close video
            video.close()
            
            # Get compressed file size
            output_size = os.path.getsize(output_path) / (1024*1024)  # MB
            compression_ratio = (1 - (output_size / input_size)) * 100
            
            print(f"\nCompression complete!")
            print(f"Original size: {input_size:.2f} MB")
            print(f"Compressed size: {output_size:.2f} MB")
            print(f"Compression ratio: {compression_ratio:.1f}%")
            
            # Remove original AVI file
            os.remove(input_path)
            print(f"Removed original AVI file: {input_path}")
            
            return True
            
        except Exception as e:
            print(f"Error during compression: {str(e)}")
            return False

    def process_video(self, input_path, output_path, preview=False, compress=True):
        try:
            cap = cv2.VideoCapture(input_path)
            if not cap.isOpened():
                print("Error: Could not open video file")
                return
            
            # Get video properties
            width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            fps = int(cap.get(cv2.CAP_PROP_FPS))
            
            # Create output path in same directory as script
            script_dir = os.path.dirname(os.path.abspath(__file__))
            output_path = os.path.join(script_dir, output_path)
            print(f"\nAttempting to save video to: {output_path}")
            
            # Try different codecs
            codecs = [
                ('H264', '.mp4'),  # Try H.264 first
                ('avc1', '.mp4'),  # Then AVC1
                ('mp4v', '.mp4'),  # Then regular MP4V
                ('XVID', '.avi'),  # Fallback to AVI
                ('MJPG', '.avi')   # Last resort
            ]
            
            out = None
            for codec, ext in codecs:
                try:
                    test_path = os.path.splitext(output_path)[0] + ext
                    print(f"\nTrying codec {codec} with output: {test_path}")
                    fourcc = cv2.VideoWriter_fourcc(*codec)
                    # Try with different parameters for better compatibility
                    out = cv2.VideoWriter(
                        test_path,
                        fourcc,
                        fps,
                        (width, height),
                        isColor=True
                    )
                    if out.isOpened():
                        output_path = test_path
                        print(f"Successfully created video writer with codec: {codec}")
                        break
                    else:
                        out.release()
                except Exception as e:
                    print(f"Failed with codec {codec}: {str(e)}")
                    if out:
                        out.release()
            
            if not out or not out.isOpened():
                print("Error: Could not create output video file with any codec")
                return
            
            # Get total frame count
            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            print(f"\nTotal frames in video: {total_frames}")
            print(f"Video FPS: {fps}")
            print(f"Expected duration: {total_frames/fps:.2f} seconds")
            print("\nProcessing video...")
            
            frame_count = 0
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    print(f"\nReached end of video after {frame_count} frames")
                    break

                # Process frame
                image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                image.flags.writeable = False
                results = self.pose.process(image)
                image.flags.writeable = True
                image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
                
                try:
                    landmarks = results.pose_landmarks.landmark
                    
                    # Get coordinates
                    shoulder = [landmarks[self.mp_pose.PoseLandmark.LEFT_SHOULDER.value].x,
                              landmarks[self.mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
                    elbow = [landmarks[self.mp_pose.PoseLandmark.LEFT_ELBOW.value].x,
                            landmarks[self.mp_pose.PoseLandmark.LEFT_ELBOW.value].y]
                    wrist = [landmarks[self.mp_pose.PoseLandmark.LEFT_WRIST.value].x,
                            landmarks[self.mp_pose.PoseLandmark.LEFT_WRIST.value].y]
                    hip = [landmarks[self.mp_pose.PoseLandmark.LEFT_HIP.value].x,
                          landmarks[self.mp_pose.PoseLandmark.LEFT_HIP.value].y]
                    
                    # Get back marker coordinates
                    left_shoulder_back = [landmarks[self.mp_pose.PoseLandmark.LEFT_SHOULDER.value].x,
                                        landmarks[self.mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
                    right_shoulder_back = [landmarks[self.mp_pose.PoseLandmark.RIGHT_SHOULDER.value].x,
                                         landmarks[self.mp_pose.PoseLandmark.RIGHT_SHOULDER.value].y]
                    
                    # Calculate angles
                    elbow_angle = self.calculate_angle(shoulder, elbow, wrist)
                    shoulder_angle = self.calculate_angle(hip, shoulder, elbow)
                    
                    # Calculate spine landmarks
                    spine_landmarks = self.calculate_spine_landmarks(left_shoulder_back, right_shoulder_back, hip)
                    
                    # Visualize
                    h, w, c = image.shape
                    
                    # Convert coordinates to pixel values
                    shoulder_px = (int(shoulder[0] * w), int(shoulder[1] * h))
                    elbow_px = (int(elbow[0] * w), int(elbow[1] * h))
                    wrist_px = (int(wrist[0] * w), int(wrist[1] * h))
                    hip_px = (int(hip[0] * w), int(hip[1] * h))
                    
                    # Convert back marker coordinates to pixel values
                    left_shoulder_px = (int(left_shoulder_back[0] * w), int(left_shoulder_back[1] * h))
                    right_shoulder_px = (int(right_shoulder_back[0] * w), int(right_shoulder_back[1] * h))
                    
                    # Draw extended line first (background)
                    extended_line_points = self.extend_line_to_frame(wrist_px, elbow_px, w, h)
                    cv2.line(image, extended_line_points[0], extended_line_points[1], (0, 255, 255), 2)
                    
                    # Draw skeleton and angles
                    for landmark in self.landmark_list:
                        x = int(landmarks[landmark.value].x * w)
                        y = int(landmarks[landmark.value].y * h)
                        cv2.circle(image, (x, y), 5, (255, 255, 255), -1)
                    
                    cv2.line(image, shoulder_px, elbow_px, (255, 255, 0), 3)
                    cv2.line(image, elbow_px, wrist_px, (255, 255, 0), 3)
                    
                    # Draw back line
                    cv2.line(image, left_shoulder_px, right_shoulder_px, (255, 0, 255), 3)  # Magenta for back line
                    
                    # Draw spine landmarks
                    spine_colors = [(255, 0, 0), (0, 255, 0), (0, 0, 255)]  # Blue, Green, Red for different spine levels
                    for i, spine_point in enumerate(spine_landmarks):
                        spine_px = (int(spine_point[0] * w), int(spine_point[1] * h))
                        cv2.circle(image, spine_px, 6, spine_colors[i], -1)
                    
                    # Connect spine landmarks
                    for i in range(len(spine_landmarks) - 1):
                        spine1_px = (int(spine_landmarks[i][0] * w), int(spine_landmarks[i][1] * h))
                        spine2_px = (int(spine_landmarks[i+1][0] * w), int(spine_landmarks[i+1][1] * h))
                        cv2.line(image, spine1_px, spine2_px, (0, 255, 255), 2)  # Yellow spine line
                    
                    cv2.circle(image, elbow_px, 10, (0, 0, 255), -1)
                    cv2.circle(image, shoulder_px, 10, (0, 0, 255), -1)
                    
                    # Highlight back markers
                    cv2.circle(image, left_shoulder_px, 8, (0, 255, 0), -1)   # Green for left shoulder
                    cv2.circle(image, right_shoulder_px, 8, (0, 255, 0), -1)  # Green for right shoulder
                    
                    cv2.putText(image, f"Elbow: {int(elbow_angle)}", 
                               (elbow_px[0]-50, elbow_px[1]+50),
                               cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
                    cv2.putText(image, f"Shoulder: {int(shoulder_angle)}", 
                               (shoulder_px[0]-50, shoulder_px[1]-30),
                               cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
                    
                except Exception as e:
                    print(f"\nFrame {frame_count} processing error: {e}")
                    # For frames where pose detection fails, write the original frame
                    image = frame
                
                # Write frame
                out.write(image)
                frame_count += 1
                
                # Show progress
                if frame_count % 30 == 0:
                    percent_done = (frame_count / total_frames) * 100
                    print(f"Processed {frame_count}/{total_frames} frames ({percent_done:.1f}%)")
                
                # Show preview if enabled
                if preview:
                    cv2.imshow('Preview', image)
                    if cv2.waitKey(1) & 0xFF == ord('q'):
                        print("\nProcessing interrupted by user")
                        break
            
            # Clean up
            cap.release()
            out.release()
            cv2.destroyAllWindows()
            
            # Verify file was created
            if os.path.exists(output_path):
                final_size = os.path.getsize(output_path) / (1024*1024)
                print(f"\nSuccess! Video saved to: {output_path}")
                print(f"File size: {final_size:.2f} MB")
                print(f"Processed frames: {frame_count}/{total_frames}")
                print(f"Actual duration: {frame_count/fps:.2f} seconds")
                
                # If the output is AVI and compression is enabled, try to compress it to MP4
                if compress and output_path.lower().endswith('.avi'):
                    mp4_path = os.path.splitext(output_path)[0] + '.mp4'
                    if self.compress_to_mp4(output_path, mp4_path):
                        print(f"\nSuccessfully compressed to MP4: {mp4_path}")
                    else:
                        print("\nFailed to compress to MP4, keeping original AVI file")
            else:
                print("\nError: Output file was not created")
            
        except Exception as e:
            print(f"\nError during video processing: {e}")
            sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process video with row form analysis including back markers.')
    parser.add_argument('--input', type=str, default="/Users/kevinrooster/Downloads/row.mov", help='Input video path')
    parser.add_argument('--output', type=str, default="analyzed_row", help='Output video path')
    parser.add_argument('--preview', action='store_true', help='Enable preview window')
    parser.add_argument('--no-compress', action='store_true', help='Disable compression')
    args = parser.parse_args()

    analyzer = RowAnalyzer()
    analyzer.process_video(args.input, args.output, preview=args.preview, compress=not args.no_compress) 