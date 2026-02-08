FROM python:3.11-slim

ENV FLAGS_fraction_of_cpu_memory_to_use=0.3 \
    OMP_NUM_THREADS=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install Python packages only
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Download models (with fallback)
RUN python -c "try:\n    from paddleocr import PaddleOCR\n    ocr = PaddleOCR(lang='it', use_angle_cls=False, show_log=False)\nexcept: pass"

# Copy app
COPY app.py .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
