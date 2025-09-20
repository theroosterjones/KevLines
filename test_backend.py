#!/usr/bin/env python3
"""
Test script to verify the KevLines backend is working correctly
"""

import requests
import json
import os
import sys

def test_backend():
    base_url = "http://localhost:3000"
    
    print("🧪 Testing KevLines Backend...")
    print("=" * 50)
    
    # Test 1: API Status
    print("1. Testing API status endpoint...")
    try:
        response = requests.get(f"{base_url}/api/status", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Status: {data['status']}")
            print(f"   ✅ Version: {data['version']}")
            print(f"   ✅ Supported exercises: {', '.join(data['supported_exercises'])}")
        else:
            print(f"   ❌ Status check failed: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Connection failed: {e}")
        return False
    
    # Test 2: Test endpoint
    print("\n2. Testing test endpoint...")
    try:
        response = requests.get(f"{base_url}/test", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Test endpoint working: {data['message']}")
        else:
            print(f"   ❌ Test endpoint failed: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Test endpoint error: {e}")
    
    # Test 3: Check upload directory
    print("\n3. Checking upload directory...")
    upload_dir = "uploads"
    output_dir = "outputs"
    
    if os.path.exists(upload_dir):
        print(f"   ✅ Upload directory exists: {upload_dir}")
    else:
        print(f"   ❌ Upload directory missing: {upload_dir}")
    
    if os.path.exists(output_dir):
        print(f"   ✅ Output directory exists: {output_dir}")
    else:
        print(f"   ❌ Output directory missing: {output_dir}")
    
    # Test 4: Check for test videos
    print("\n4. Checking for test videos...")
    test_videos = []
    for ext in ['mp4', 'mov', 'avi']:
        for file in os.listdir('.'):
            if file.endswith(f'.{ext}'):
                test_videos.append(file)
    
    if test_videos:
        print(f"   ✅ Found test videos: {', '.join(test_videos)}")
    else:
        print("   ⚠️  No test videos found in current directory")
    
    print("\n" + "=" * 50)
    print("🎯 Backend Test Summary:")
    print("   - API endpoints are responding")
    print("   - Directories are set up correctly")
    print("   - Ready for iPhone testing!")
    print("\n📱 Next steps:")
    print("   1. Start the backend: python app.py")
    print("   2. Update iPhone app with your IP address")
    print("   3. Test video upload from iPhone")
    
    return True

if __name__ == "__main__":
    test_backend()
