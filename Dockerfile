FROM python:3.11-slim

ENV FLAGS_fraction_of_cpu_memory_to_use=0.3 \
    OMP_NUM_THREADS=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install system dependencies (required for PaddlePaddle)
RUN apt-get update || true && \
    apt-get install -y --no-install-recommends libgomp1 || true && \
    rm -rf /var/lib/apt/lists/* || true

# Copy and install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy app
COPY app.py .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
