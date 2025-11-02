FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Python 3.10 and system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3-pip \
    git \
    wget \
    curl \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Create working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu118 -r requirements.txt

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI

# Install ComfyUI dependencies
WORKDIR /app/ComfyUI
RUN pip install --no-cache-dir -r requirements.txt

# Install ComfyUI Manager
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git /app/ComfyUI/custom_nodes/ComfyUI-Manager

# Install ComfyUI Manager dependencies
WORKDIR /app/ComfyUI/custom_nodes/ComfyUI-Manager
RUN pip install --no-cache-dir -r requirements.txt

# Copy entrypoint script
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Create necessary directories
RUN mkdir -p /app/ComfyUI/models /app/ComfyUI/output /app/ComfyUI/input

# Expose port (ComfyUI uses 8188 by default)
EXPOSE 8188

# Set entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]

