import os
import json
import tempfile
from datetime import datetime
from flask import Flask, render_template, request, jsonify, send_file
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024 * 1024  # 100MB max file size
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['OUTPUT_FOLDER'] = 'outputs'

# Ensure directories exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['OUTPUT_FOLDER'], exist_ok=True)

ALLOWED_EXTENSIONS = {'wav', 'mp3', 'm4a', 'flac', 'aac', 'ogg', 'txt'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def simple_transcribe_audio(audio_file_path):
    """Simple transcription - just returns a placeholder for now"""
    return f"Audio file processed: {os.path.basename(audio_file_path)}\n\nThis is a placeholder transcription. For full functionality, install the complete dependencies:\n\npip install -r requirements.txt\n\nThen use the full app.py instead of simple_app.py"

def simple_summarize_text(text):
    """Simple summary - just returns a placeholder for now"""
    return f"Summary placeholder for: {text[:100]}...\n\nFor AI-powered summarization, install OpenAI and set your API key."

@app.route('/')
def index():
    return render_template('simple_index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{timestamp}_{filename}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        return jsonify({
            'success': True,
            'filename': filename,
            'message': 'File uploaded successfully'
        })
    
    return jsonify({'error': 'Invalid file type'}), 400

@app.route('/transcribe', methods=['POST'])
def transcribe():
    data = request.get_json()
    filename = data.get('filename')
    
    if not filename:
        return jsonify({'error': 'No filename provided'}), 400
    
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    
    if not os.path.exists(filepath):
        return jsonify({'error': 'File not found'}), 404
    
    # Simple transcription
    transcription = simple_transcribe_audio(filepath)
    
    # Simple summary
    summary = simple_summarize_text(transcription)
    
    # Save transcription and summary to file
    output_filename = f"transcript_{filename.rsplit('.', 1)[0]}.txt"
    output_path = os.path.join(app.config['OUTPUT_FOLDER'], output_filename)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("MEETING TRANSCRIPT (SIMPLE VERSION)\n")
        f.write("=" * 50 + "\n\n")
        f.write("TRANSCRIPTION:\n")
        f.write("-" * 20 + "\n")
        f.write(transcription)
        f.write("\n\nSUMMARY:\n")
        f.write("-" * 20 + "\n")
        f.write(summary)
        f.write(f"\n\nGenerated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        f.write("\n\nNOTE: This is a simplified version. For full functionality, use app.py with all dependencies.")
    
    return jsonify({
        'success': True,
        'transcription': transcription,
        'summary': summary,
        'output_file': output_filename
    })

@app.route('/download/<filename>')
def download_file(filename):
    filepath = os.path.join(app.config['OUTPUT_FOLDER'], filename)
    if os.path.exists(filepath):
        return send_file(filepath, as_attachment=True)
    return jsonify({'error': 'File not found'}), 404

@app.route('/status')
def status():
    return jsonify({
        'status': 'running',
        'version': 'simple',
        'message': 'Meeting Transcriber (Simple Version) is running'
    })

if __name__ == '__main__':
    print("🚀 Starting Meeting Transcriber (Simple Version)")
    print("📱 Access from other machines using your computer's IP address")
    print("🌐 Web interface: http://0.0.0.0:8080")
    print("📊 Status check: http://0.0.0.0:8080/status")
    print("\n⚠️  This is a simplified version. For full transcription and AI summarization,")
    print("   install dependencies and use app.py instead.")
    print("\n" + "="*60)
    
    app.run(debug=False, host='0.0.0.0', port=8080) 