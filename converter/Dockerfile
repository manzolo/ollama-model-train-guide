FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app.py .
COPY templates/ templates/

# Create upload directory
RUN mkdir -p /tmp/uploads

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
