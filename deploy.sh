#!/bin/bash

# Meeting Transcriber Deployment Script
echo "🚀 Setting up Meeting Transcriber..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.7+ first."
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 is not installed. Please install pip first."
    exit 1
fi

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📚 Installing dependencies..."
pip install -r requirements.txt

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p uploads outputs

# Copy environment file
if [ ! -f .env ]; then
    echo "⚙️  Setting up environment file..."
    cp env_example.txt .env
    echo "📝 Please edit .env file and add your OpenAI API key"
fi

echo "✅ Setup complete!"
echo ""
echo "To start the application:"
echo "1. Activate virtual environment: source venv/bin/activate"
echo "2. Run the app: python app.py"
echo "3. Access via: http://localhost:8080"
echo ""
echo "For Docker deployment:"
echo "1. Build: docker build -t meeting-transcriber ."
echo "2. Run: docker run -p 8080:8080 meeting-transcriber"
echo ""
echo "For Docker Compose:"
echo "1. Run: docker-compose up -d" 