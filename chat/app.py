#!/usr/bin/env python3
"""
Simple Chat Interface for Ollama Models
"""

from flask import Flask, render_template, request, jsonify, Response
import requests
import json
import os

app = Flask(__name__)
OLLAMA_API = 'http://ollama:11434'
MODELS_DIR = '/models'

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

@app.route('/api/modelfiles')
def get_modelfiles():
    modelfiles = []
    try:
        # Walk through models directory to find Modelfiles
        for root, dirs, files in os.walk(MODELS_DIR):
            if 'Modelfile' in files:
                full_path = os.path.join(root, 'Modelfile')
                # Create a relative path for display, removing /models/ prefix
                rel_path = os.path.relpath(full_path, MODELS_DIR)
                modelfiles.append({
                    'path': full_path,
                    'name': rel_path
                })
        
        # Sort by name
        modelfiles.sort(key=lambda x: x['name'])
        return jsonify({'modelfiles': modelfiles})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/create-model', methods=['POST'])
def create_model():
    import subprocess
    import re
    try:
        data = request.json
        model_name = data.get('name')
        modelfile_path = data.get('path')

        if not model_name or not modelfile_path:
            return jsonify({'error': 'Missing name or path'}), 400

        # Check if Modelfile exists
        if not os.path.exists(modelfile_path):
             return jsonify({'error': 'Modelfile not found'}), 404

        # Stream response from Ollama CLI
        def generate():
            try:
                yield json.dumps({'status': f'Creating model {model_name}...'}) + '\n'

                # Use ollama CLI command via docker exec directly
                # The chat container can exec into the ollama container
                process = subprocess.Popen(
                    ['docker', 'exec', 'ollama', 'ollama', 'create', model_name, '-f', modelfile_path],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    bufsize=1
                )

                # Stream the output
                for line in process.stdout:
                    line = line.strip()
                    if line:
                        # Remove ANSI escape codes
                        line = re.sub(r'\x1b\[[0-9;]*[a-zA-Z?]', '', line)
                        yield json.dumps({'status': line}) + '\n'

                # Wait for process to complete
                process.wait()

                if process.returncode == 0:
                    yield json.dumps({'status': 'success'}) + '\n'
                else:
                    yield json.dumps({'error': f'Process exited with code {process.returncode}'}) + '\n'

            except Exception as e:
                yield json.dumps({'error': str(e)}) + '\n'

        return Response(generate(), mimetype='text/event-stream')
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/modelfile', methods=['GET'])
def get_modelfile():
    try:
        path = request.args.get('path')
        if not path or not os.path.exists(path):
            return jsonify({'error': 'Modelfile not found'}), 404

        with open(path, 'r') as f:
            content = f.read()

        return jsonify({'content': content, 'path': path})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/modelfile', methods=['POST'])
def create_modelfile():
    try:
        data = request.json
        name = data.get('name')
        content = data.get('content', '')

        if not name:
            return jsonify({'error': 'Missing name'}), 400

        # Create in models/custom directory
        modelfile_dir = os.path.join(MODELS_DIR, 'custom', name)
        os.makedirs(modelfile_dir, exist_ok=True)

        modelfile_path = os.path.join(modelfile_dir, 'Modelfile')

        if os.path.exists(modelfile_path):
            return jsonify({'error': 'Modelfile already exists'}), 409

        with open(modelfile_path, 'w') as f:
            f.write(content)

        return jsonify({'success': True, 'path': modelfile_path})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/modelfile', methods=['PUT'])
def update_modelfile():
    try:
        data = request.json
        path = data.get('path')
        content = data.get('content')

        if not path or content is None:
            return jsonify({'error': 'Missing path or content'}), 400

        if not os.path.exists(path):
            return jsonify({'error': 'Modelfile not found'}), 404

        with open(path, 'w') as f:
            f.write(content)

        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/modelfile', methods=['DELETE'])
def delete_modelfile():
    try:
        path = request.args.get('path')

        if not path or not os.path.exists(path):
            return jsonify({'error': 'Modelfile not found'}), 404

        # Only allow deletion from custom directory for safety
        if '/custom/' not in path:
            return jsonify({'error': 'Can only delete custom Modelfiles'}), 403

        os.remove(path)

        # Try to remove parent directory if empty
        parent_dir = os.path.dirname(path)
        try:
            if not os.listdir(parent_dir):
                os.rmdir(parent_dir)
        except:
            pass

        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/delete-model', methods=['DELETE'])
def delete_model():
    try:
        model_name = request.args.get('name')

        if not model_name:
            return jsonify({'error': 'Missing model name'}), 400

        response = requests.delete(
            f'{OLLAMA_API}/api/delete',
            json={'name': model_name}
        )

        if response.status_code == 200:
            return jsonify({'success': True})
        else:
            return jsonify({'error': 'Failed to delete model'}), response.status_code
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
