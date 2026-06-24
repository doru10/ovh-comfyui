FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# ============================================================
# SYSTEM
# ============================================================
RUN apt-get update && apt-get install -y \
    git curl wget ffmpeg \
    python3 python3-pip \
    libgl1 libglib2.0-0 \
    build-essential cmake python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# ============================================================
# OVH PERFORMANCE LAYER (CACHE + SPEED)
# ============================================================
ENV HF_HOME=/workspace/models/hf_cache
ENV HUGGINGFACE_HUB_CACHE=/workspace/models/hf_cache
ENV TRANSFORMERS_CACHE=/workspace/models/hf_cache
ENV TORCH_HOME=/workspace/models/torch_cache
ENV XDG_CACHE_HOME=/workspace/models/cache
ENV PIP_CACHE_DIR=/workspace/models/pip_cache

ENV HF_XET_HIGH_PERFORMANCE=1
ENV GIT_TERMINAL_PROMPT=0
ENV GIT_LFS_SKIP_SMUDGE=1

# ============================================================
# PYTORCH
# ============================================================
RUN pip install --no-cache-dir --upgrade pip

RUN pip install --no-cache-dir \
    torch==2.2.2+cu121 torchvision==0.17.2+cu121 torchaudio==2.2.2+cu121 \
    --index-url https://download.pytorch.org/whl/cu121

# ============================================================
# COMFYUI CORE
# ============================================================
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip install --no-cache-dir -r requirements.txt

# ============================================================
# BASE AI STACK
# ============================================================
RUN pip install --no-cache-dir \
    numpy einops safetensors tqdm pillow \
    huggingface_hub accelerate transformers \
    sentencepiece protobuf requests aiohttp psutil \
    opencv-python-headless imageio imageio-ffmpeg av \
    onnxruntime-gpu xformers insightface \
    diffusers hf_transfer \
    gitpython pyyaml scipy scikit-image ffmpeg-python decord mediapipe

# ============================================================
# COMFYUI MANAGER
# ============================================================
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git \
    custom_nodes/ComfyUI-Manager \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt || true

# ============================================================
# CORE NODE STACK
# ============================================================
RUN git clone --depth 1 https://github.com/civitai/civitai_comfy_nodes.git custom_nodes/civitai_comfy_nodes || true
RUN git clone --depth 1 https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git custom_nodes/ComfyUI_UltimateSDUpscale || true
RUN git clone --depth 1 https://github.com/ssitu/ComfyUI_SDXL_EmptyLatentImage.git custom_nodes/ComfyUI_SDXL_EmptyLatentImage || true

# ============================================================
# VIDEO STACK
# ============================================================
RUN git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite
RUN git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git custom_nodes/ComfyUI-AnimateDiff-Evolved || true
RUN git clone --depth 1 https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git custom_nodes/ComfyUI-Frame-Interpolation || true
RUN pip install --no-cache-dir cupy-cuda12x || true

# ============================================================
# CONTROL STACK
# ============================================================
RUN git clone --depth 1 https://github.com/cubiq/ComfyUI_IPAdapter_plus.git custom_nodes/ComfyUI_IPAdapter_plus
RUN git clone --depth 1 https://github.com/Fannovel16/comfyui_controlnet_aux.git custom_nodes/comfyui_controlnet_aux

# ============================================================
# CORE PACKS
# ============================================================
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Pack.git custom_nodes/ComfyUI-Impact-Pack || true
RUN git clone --depth 1 https://github.com/WASasquatch/was-node-suite-comfyui.git custom_nodes/was-node-suite-comfyui || true
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Logic.git custom_nodes/ComfyUI-Logic || true
RUN git clone --depth 1 https://github.com/BlenderNeko/ComfyUI_ADV_CLIP_emb.git custom_nodes/ComfyUI_ADV_CLIP_emb

# ============================================================
# UI STACK
# ============================================================
RUN git clone --depth 1 https://github.com/cubiq/ComfyUI_essentials.git custom_nodes/ComfyUI_essentials || true
RUN git clone --depth 1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git custom_nodes/ComfyUI-Custom-Scripts || true
RUN git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git custom_nodes/rgthree-comfy || true

# ============================================================
# FLUX FOUNDATION
# ============================================================
RUN pip install --no-cache-dir --no-deps \
    git+https://github.com/huggingface/diffusers.git

RUN mkdir -p /workspace/models/flux \
    /workspace/models/checkpoints \
    /workspace/models/loras \
    /workspace/models/vae \
    /workspace/models/controlnet \
    /workspace/models/embeddings

# ============================================================
# AUTO INSTALL ALL NODE REQUIREMENTS (IMPORTANT FIX)
# ============================================================
# More robust node dependency installation
RUN find custom_nodes -name "requirements.txt" -exec pip install --no-cache-dir --no-deps -r {} \; || true
RUN find custom_nodes -name "requirements-no-cupy.txt" -exec pip install --no-cache-dir -r {} \; || true

# ============================================================
# MODEL STRUCTURE (A1111-LIKE ORGANIZATION)
# ============================================================
RUN mkdir -p /workspace/models/{checkpoints,loras,vae,controlnet,embeddings}

# ============================================================
# STARTUP SCRIPT (WARM CACHE + FAST BOOT)
# ============================================================
RUN mkdir -p /workspace/scripts

RUN printf '%s\n' \
'#!/bin/bash' \
'set -e' \
'' \
'echo "== ComfyUI OVH BOOT ==" ' \
'' \
'# warm imports for faster startup' \
'python3 -c "import torch; import comfy; import comfy.model_management" || true' \
'' \
'# download SDXL if missing' \
'if [ ! -f /workspace/models/checkpoints/sdxl.safetensors ]; then' \
'  echo "Downloading SDXL..."' \
'  curl -L -o /workspace/models/checkpoints/sdxl.safetensors \' \
'  https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors' \
'fi' \
'' \
'echo "Startup complete"' \
'' \
'exec python3 main.py --listen 0.0.0.0 --port 8188' \
> /workspace/scripts/start.sh

RUN chmod +x /workspace/scripts/start.sh

# ============================================================
# PERMISSIONS (IMPORTANT FIX)
# ============================================================
RUN mkdir -p /workspace/models /workspace/.cache && \
    chown -R 42420:42420 /workspace

ENV HOME=/workspace
USER 42420:42420

# ============================================================
# START
# ============================================================
CMD ["/workspace/scripts/start.sh"]
