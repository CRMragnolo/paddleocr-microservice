FROM python:3.11-slim

# Environment variables for memory optimization (Render free tier: 512MB RAM)
ENV FLAGS_fraction_of_cpu_memory_to_use=0.3 \
    OMP_NUM_THREADS=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgomp1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download Italian OCR models at build time (not at runtime)
# This speeds up container startup
RUN python -c "from paddleocr import PaddleOCR; ocr = PaddleOCR(lang='it', use_angle_cls=False, show_log=False)"

# Copy application code
COPY app.py .

# Expose port
EXPOSE 8000

# Run the application with single worker (memory optimization)
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
