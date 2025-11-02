#!/bin/bash

# Entrypoint script for ComfyUI on RunPod

set -e

# Change to ComfyUI directory
cd /app/ComfyUI

# Configurable environment variables
PORT=${PORT:-8188}
HOST=${HOST:-0.0.0.0}

# Check if CUDA is available
if command -v nvidia-smi &> /dev/null; then
    echo "GPU detected:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
else
    echo "Warning: nvidia-smi not found. Running in CPU mode."
fi

# Verify Python is available
if ! command -v python &> /dev/null; then
    echo "Error: Python not found"
    exit 1
fi

echo "Starting ComfyUI on ${HOST}:${PORT}..."
echo "Working directory: $(pwd)"

# Run ComfyUI
exec python main.py --listen ${HOST} --port ${PORT}

