FROM python:3.11-slim

# Environment variables for memory optimization
ENV FLAGS_fraction_of_cpu_memory_to_use=0.3 \
    OMP_NUM_THREADS=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install system dependencies with retry and minimal packages
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    libgomp1 \
    libglib2.0-0 \
    libgl1-mesa-glx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Download OCR models at build time
RUN python -c "from paddleocr import PaddleOCR; ocr = PaddleOCR(lang='it', use_angle_cls=False, show_log=False)" || true

# Copy application
COPY app.py .

# Expose port
EXPOSE 8000

# Run application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
