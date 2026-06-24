FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git python3 python3-pip libgl1 libglib2.0-0 \
    build-essential cmake python3-dev \
    && rm -rf /var/lib/apt/lists/*

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

# Install nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt

RUN git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git custom_nodes/ComfyUI-WanVideoWrapper
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt

RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt

RUN git clone https://github.com/naxci1/ComfyUI-FlashVSR_Stable.git custom_nodes/ComfyUI-FlashVSR
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-FlashVSR/requirements.txt
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-FlashVSR/requirements.txt

RUN git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git custom_nodes/ComfyUI-Frame-Interpolation
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-Frame-Interpolation/requirements.txt

RUN git clone https://github.com/willmiao/ComfyUI-Lora-Manager.git custom_nodes/comfyui-lora-manager
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-Lora-Manager/requirements.txt

# Impact Pack (For Auto-Detailing & Upscaling)
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git custom_nodes/ComfyUI-Impact-Pack
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-Impact-Pack/requirements.txt

# WAS Node Suite (The "Swiss Army Knife" of image processing)
RUN git clone https://github.com/WASasquatch/was-node-suite-comfyui.git custom_nodes/was-node-suite-comfyui
RUN pip install --no-cache-dir -r custom_nodes/was-node-suite-comfyui/requirements.txt

# LayerStyle (For Photoshop-like editing)
RUN git clone https://github.com/chflame163/ComfyUI_LayerStyle.git custom_nodes/ComfyUI_LayerStyle
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI_LayerStyle/requirements.txt

# Civitai Integration
RUN git clone https://github.com/civitai/civitai_comfy_nodes.git custom_nodes/civitai_comfy_nodes
RUN pip install --no-cache-dir -r custom_nodes/civitai_comfy_nodes/requirements.txt

# Inspire Pack (For LoRA control)
RUN git clone https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git custom_nodes/ComfyUI-Inspire-Pack
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-Inspire-Pack/requirements.txt

# IPAdapter (For image-to-image/style transfer)
RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git custom_nodes/ComfyUI_IPAdapter_plus
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI_IPAdapter_plus/requirements.txt

# ControlNet Auxiliary Preprocessors
RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git custom_nodes/comfyui_controlnet_aux
RUN pip install --no-cache-dir -r custom_nodes/comfyui_controlnet_aux/requirements.txt



# Fix permissions for the strict OVH user
RUN chown -R 42420:42420 /workspace
ENV HOME=/workspace

# Force the OVH user
USER 42420:42420

# Start ComfyUI directly
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
