#!/usr/bin/env python3
"""
Spreadsheet to JSONL Converter Service
Converts Excel/CSV files to JSONL format for model training
"""

from flask import Flask, request, render_template, send_file, jsonify, after_this_request
import pandas as pd
import json
import os
from werkzeug.utils import secure_filename
import tempfile

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
app.config['UPLOAD_FOLDER'] = '/tmp/uploads'
app.config['OUTPUT_FOLDER'] = '/data/training'

ALLOWED_EXTENSIONS = {'xlsx', 'xls', 'csv'}

os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['OUTPUT_FOLDER'], exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/convert', methods=['POST'])
def convert():
    temp_jsonl = None
    try:
        # Validate file upload
        if 'file' not in request.files:
            return jsonify({'error': 'No file uploaded'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Use .xlsx, .xls, or .csv'}), 400
        
        # Get column mappings and save option
        instruction_col = request.form.get('instruction_col', 'instruction')
        output_col = request.form.get('output_col', 'output')
        save_to_server = request.form.get('save_to_server', 'false').lower() == 'true'
        
        # Save uploaded file
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # Read file
        if filename.endswith('.csv'):
            df = pd.read_csv(filepath)
        else:
            df = pd.read_excel(filepath)
        
        # Validate columns
        if instruction_col not in df.columns:
            os.remove(filepath)
            return jsonify({'error': f'Column "{instruction_col}" not found in file'}), 400
        if output_col not in df.columns:
            os.remove(filepath)
            return jsonify({'error': f'Column "{output_col}" not found in file'}), 400
        
        # Convert to JSONL
        output_filename = filename.rsplit('.', 1)[0] + '.jsonl'
        
        # Create temporary JSONL file
        temp_jsonl = tempfile.NamedTemporaryFile(mode='w', suffix='.jsonl', delete=False, encoding='utf-8')
        rows_converted = 0
        
        for _, row in df.iterrows():
            if pd.notna(row[instruction_col]) and pd.notna(row[output_col]):
                json_obj = {
                    'instruction': str(row[instruction_col]).strip(),
                    'output': str(row[output_col]).strip()
                }
                temp_jsonl.write(json.dumps(json_obj, ensure_ascii=False) + '\n')
                rows_converted += 1
        
        temp_jsonl.close()
        
        # Optionally save to server
        if save_to_server:
            output_path = os.path.join(app.config['OUTPUT_FOLDER'], output_filename)
            os.rename(temp_jsonl.name, output_path)
            os.remove(filepath)
            return jsonify({
                'success': True,
                'message': f'Converted and saved to {output_filename}',
                'output_file': output_filename,
                'rows_converted': rows_converted
            })
        
        # Clean up uploaded file
        os.remove(filepath)
        
        # Return file as download with cleanup callback
        @after_this_request
        def remove_file(response):
            try:
                os.remove(temp_jsonl.name)
            except Exception as error:
                app.logger.error(f"Error removing temp file: {error}")
            return response
        
        return send_file(
            temp_jsonl.name,
            as_attachment=True,
            download_name=output_filename,
            mimetype='application/jsonl'
        )
    
    except Exception as e:
        app.logger.error(f"Conversion error: {str(e)}")
        if temp_jsonl and hasattr(temp_jsonl, 'name') and os.path.exists(temp_jsonl.name):
            try:
                os.remove(temp_jsonl.name)
            except:
                pass
        return jsonify({'error': str(e)}), 500

@app.route('/preview', methods=['POST'])
def preview():
    filepath = None
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file uploaded'}), 400
        
        file = request.files['file']
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type'}), 400
        
        # Save temporarily
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], 'preview_' + filename)
        file.save(filepath)
        
        # Read file
        if filename.endswith('.csv'):
            df = pd.read_csv(filepath, nrows=5)
        else:
            # Read Excel with explicit engine
            df = pd.read_excel(filepath, nrows=5, engine='openpyxl')
        
        # Clean up
        if filepath and os.path.exists(filepath):
            os.remove(filepath)
        
        return jsonify({
            'columns': df.columns.tolist(),
            'preview': df.head().to_dict('records')
        })
    
    except Exception as e:
        app.logger.error(f"Preview error: {str(e)}")
        # Clean up on error
        if filepath and os.path.exists(filepath):
            try:
                os.remove(filepath)
            except:
                pass
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
