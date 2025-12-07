#!/usr/bin/env python3
"""
Simple Chat Interface for Ollama Models
"""

from flask import Flask, render_template, request, jsonify, Response
import requests
import json

app = Flask(__name__)
OLLAMA_API = 'http://ollama:11434'

@app.route('/')
def index():
    return render_template('chat.html')

@app.route('/api/models')
def get_models():
    try:
        response = requests.get(f'{OLLAMA_API}/api/tags')
        return jsonify(response.json())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/chat', methods=['POST'])
def chat():
    try:
        data = request.json
        model = data.get('model', 'llama3.2:1b')
        message = data.get('message', '')
        
        # Stream response from Ollama
        def generate():
            response = requests.post(
                f'{OLLAMA_API}/api/generate',
                json={
                    'model': model,
                    'prompt': message,
                    'stream': True
                },
                stream=True
            )
            
            for line in response.iter_lines():
                if line:
                    yield line.decode('utf-8') + '\n'
        
        return Response(generate(), mimetype='text/event-stream')
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
