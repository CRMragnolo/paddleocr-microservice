FROM python:3.11-slim

ENV FLAGS_fraction_of_cpu_memory_to_use=0.3 \
    OMP_NUM_THREADS=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install Python packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy app
COPY app.py .

# Download models at first run (not at build time)
# This makes the build faster and more reliable

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
