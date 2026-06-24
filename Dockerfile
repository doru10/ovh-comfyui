FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# ============================================================
# SYSTEM DEPENDENCIES
# ============================================================
RUN apt-get update && apt-get install -y \
    git curl wget ffmpeg python3 python3-pip libgl1 libglib2.0-0 \
    build-essential cmake python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# ============================================================
# OVH PERFORMANCE & CACHE LAYER
# ============================================================
ENV HF_HOME=/workspace/models/hf_cache
ENV HUGGINGFACE_HUB_CACHE=/workspace/models/hf_cache
ENV TRANSFORMERS_CACHE=/workspace/models/hf_cache
ENV TORCH_HOME=/workspace/models/torch_cache
ENV XDG_CACHE_HOME=/workspace/models/cache
ENV PIP_CACHE_DIR=/workspace/models/pip_cache
ENV HF_XET_HIGH_PERFORMANCE=1

# ============================================================
# FOUNDATION: PYTORCH 2.4+ (REQUIRED)
# ============================================================
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir "numpy<2" && \
    pip install --no-cache-dir \
    torch>=2.4.0 torchvision>=0.19.0 torchaudio>=2.4.0 \
    --index-url https://download.pytorch.org/whl/cu121

# ============================================================
# COMFYUI CORE
# ============================================================
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip install --no-cache-dir --no-deps -r requirements.txt

# ============================================================
# ALL CUSTOM NODES
# ============================================================
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-WanVideoWrapper.git custom_nodes/ComfyUI-WanVideoWrapper
RUN git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite
RUN git clone --depth 1 https://github.com/naxci1/ComfyUI-FlashVSR_Stable.git custom_nodes/ComfyUI-FlashVSR
RUN git clone --depth 1 https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git custom_nodes/ComfyUI-Frame-Interpolation
RUN git clone --depth 1 https://github.com/willmiao/ComfyUI-Lora-Manager.git custom_nodes/comfyui-lora-manager
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Pack.git custom_nodes/ComfyUI-Impact-Pack
RUN git clone --depth 1 https://github.com/WASasquatch/was-node-suite-comfyui.git custom_nodes/was-node-suite-comfyui
RUN git clone --depth 1 https://github.com/chflame163/ComfyUI_LayerStyle.git custom_nodes/ComfyUI_LayerStyle
RUN git clone --depth 1 https://github.com/civitai/civitai_comfy_nodes.git custom_nodes/civitai_comfy_nodes
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git custom_nodes/ComfyUI-Inspire-Pack
RUN git clone --depth 1 https://github.com/cubiq/ComfyUI_IPAdapter_plus.git custom_nodes/ComfyUI_IPAdapter_plus
RUN git clone --depth 1 https://github.com/Fannovel16/comfyui_controlnet_aux.git custom_nodes/comfyui_controlnet_aux
RUN git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git custom_nodes/ComfyUI-AnimateDiff-Evolved
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Logic.git custom_nodes/ComfyUI-Logic
RUN git clone --depth 1 https://github.com/BlenderNeko/ComfyUI_ADV_CLIP_emb.git custom_nodes/ComfyUI_ADV_CLIP_emb
RUN git clone --depth 1 https://github.com/cubiq/ComfyUI_essentials.git custom_nodes/ComfyUI_essentials
RUN git clone --depth 1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git custom_nodes/ComfyUI-Custom-Scripts
RUN git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git custom_nodes/rgthree-comfy

# Automated installation for all requirements
RUN find custom_nodes -name "*.txt" -exec pip install --no-cache-dir --no-deps -r {} \; || true
RUN pip install --no-cache-dir --no-deps cupy-cuda12x git+https://github.com/huggingface/diffusers.git

# ============================================================
# MODELS & STARTUP
# ============================================================
RUN mkdir -p /workspace/models/{flux,checkpoints,loras,vae,controlnet,embeddings}
RUN mkdir -p /workspace/scripts
RUN printf '#!/bin/bash\nset -e\necho "== ComfyUI OVH BOOT =="\nif [ ! -f /workspace/models/checkpoints/sdxl.safetensors ]; then curl -L -o /workspace/models/checkpoints/sdxl.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors; fi\nexec python3 main.py --listen 0.0.0.0 --port 8188' > /workspace/scripts/start.sh && chmod +x /workspace/scripts/start.sh

# ============================================================
# PERMISSIONS & START
# ============================================================
RUN chown -R 42420:42420 /workspace
USER 42420:42420
CMD ["/workspace/scripts/start.sh"]
