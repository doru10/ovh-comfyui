FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git python3 python3-pip libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Install PyTorch
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Clone raw ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# Install ComfyUI dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install ComfyUI Manager (Essential for easily downloading Wan2.1 models later)
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt
RUN git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git custom_nodes/ComfyUI-WanVideoWrapper
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt


# Fix permissions for the strict OVH user
RUN chown -R 42420:42420 /workspace
ENV HOME=/workspace

# Force the OVH user
USER 42420:42420

# Start ComfyUI directly
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
