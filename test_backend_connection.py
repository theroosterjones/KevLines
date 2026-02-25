#!/usr/bin/env python3
"""
Test script to verify Python backend is working correctly
"""
import requests
import json
import os

def test_backend_connection():
    base_url = "http://localhost:3000"
    
    print("🧪 Testing KevLines Backend Connection")
    print("=" * 50)
    
    # Test 1: Check API status
    print("1. Testing API status...")
    try:
        response = requests.get(f"{base_url}/api/status", timeout=5)
        if response.status_code == 200:
            status_data = response.json()
            print(f"✅ API Status: {status_data['status']}")
            print(f"✅ Version: {status_data['version']}")
            print(f"✅ Supported exercises: {status_data['supported_exercises']}")
        else:
            print(f"❌ API Status failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ API Status error: {e}")
        return False
    
    # Test 2: Check if we have test videos
    print("\n2. Checking for test videos...")
    test_videos = []
    uploads_dir = "uploads"
    if os.path.exists(uploads_dir):
        for file in os.listdir(uploads_dir):
            if file.endswith(('.mp4', '.mov', '.avi')):
                test_videos.append(file)
                print(f"✅ Found test video: {file}")
    
    if not test_videos:
        print("⚠️ No test videos found in uploads directory")
        print("   You can add a test video to the uploads/ directory")
        return True
    
    # Test 3: Test video analysis (if we have videos)
    print(f"\n3. Testing video analysis with {test_videos[0]}...")
    try:
        # Test with the first available video
        test_video = test_videos[0]
        analysis_data = {
            "filename": test_video,
            "exercise_type": "row"  # Test with row analysis
        }
        
        response = requests.post(
            f"{base_url}/analyze",
            json=analysis_data,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Analysis successful!")
            print(f"✅ Output file: {result.get('output_file', 'N/A')}")
            if 'results' in result:
                results = result['results']
                print(f"✅ Rep count: {results.get('rep_count', 'N/A')}")
                print(f"✅ Form score: {results.get('form_score', 'N/A')}")
                print(f"✅ Message: {results.get('message', 'N/A')}")
        else:
            print(f"❌ Analysis failed: {response.status_code}")
            print(f"❌ Error: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Analysis error: {e}")
        return False
    
    print("\n🎉 All tests passed! Backend is working correctly.")
    return True

if __name__ == "__main__":
    success = test_backend_connection()
    if not success:
        print("\n❌ Backend tests failed. Please check your Python backend.")
        exit(1)
    else:
        print("\n✅ Backend is ready for iOS app testing!")


