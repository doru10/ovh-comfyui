FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# ============================================================
# SYSTEM
# ============================================================
RUN apt-get update && apt-get install -y \
    git curl wget unzip ffmpeg \
    python3 python3-pip \
    libgl1 libglib2.0-0 \
    build-essential cmake python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace


# ============================================================
# GIT SAFETY (KEEP)
# ============================================================
ENV GIT_TERMINAL_PROMPT=0
ENV GIT_LFS_SKIP_SMUDGE=1


# ============================================================
# PYTORCH
# ============================================================
RUN pip install --no-cache-dir \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121


# ============================================================
# COMFYUI CORE
# ============================================================
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip install --no-cache-dir -r requirements.txt


# ============================================================
# PYTHON STACK (UNCHANGED)
# ============================================================
RUN pip install --no-cache-dir \
    numpy einops safetensors tqdm pillow \
    huggingface_hub hf_transfer accelerate transformers \
    sentencepiece protobuf requests aiohttp psutil \
    opencv-python-headless imageio imageio-ffmpeg av \
    onnxruntime-gpu xformers insightface cupy-cuda12x


# ============================================================
# HF CONFIG
# ============================================================
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV HF_HOME=/workspace/.cache/huggingface
ENV TRANSFORMERS_CACHE=/workspace/.cache/huggingface


# ============================================================
# CORE MANAGER (KEEP GIT)
# ============================================================
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git \
    custom_nodes/ComfyUI-Manager \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt


# ============================================================
# VIDEO STACK (KEEP GIT WHERE STABLE)
# ============================================================
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-WanVideoWrapper.git \
    custom_nodes/ComfyUI-WanVideoWrapper \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt

RUN git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git \
    custom_nodes/ComfyUI-VideoHelperSuite \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt

RUN git clone --depth 1 https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git \
    custom_nodes/ComfyUI-Frame-Interpolation \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Frame-Interpolation/requirements-no-cupy.txt

RUN pip install --no-cache-dir cupy-cuda12x

RUN git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git \
    custom_nodes/ComfyUI-AnimateDiff-Evolved || true


# ============================================================
# MODEL STACK (UNCHANGED LOGIC)
# ============================================================
RUN git clone --depth 1 https://github.com/willmiao/ComfyUI-Lora-Manager.git \
    custom_nodes/ComfyUI-Lora-Manager || true

RUN git clone --depth 1 https://github.com/civitai/civitai_comfy_nodes.git \
    custom_nodes/civitai_comfy_nodes || true

RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Pack.git \
    custom_nodes/ComfyUI-Impact-Pack \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Impact-Pack/requirements.txt


# ============================================================
# ❗ FIXED: UPSCALE NODE (ZIP METHOD - OVH SAFE)
# ============================================================
RUN curl -L https://github.com/ssitu/ComfyUI_UltimateSDUpscale/archive/refs/heads/main.zip \
    -o /tmp/upscale.zip \
 && unzip /tmp/upscale.zip -d custom_nodes \
 && mv custom_nodes/ComfyUI_UltimateSDUpscale-main custom_nodes/ComfyUI_UltimateSDUpscale \
 && rm /tmp/upscale.zip


# ============================================================
# CONTROL STACK (KEEP GIT WHERE POSSIBLE)
# ============================================================
RUN git clone --depth 1 https://github.com/cubiq/ComfyUI_IPAdapter_plus.git \
    custom_nodes/ComfyUI_IPAdapter_plus || true

RUN mkdir -p models/ipadapter models/clip_vision

RUN git clone --depth 1 https://github.com/Fannovel16/comfyui_controlnet_aux.git \
    custom_nodes/comfyui_controlnet_aux \
 && pip install --no-cache-dir -r custom_nodes/comfyui_controlnet_aux/requirements.txt

RUN git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git \
    custom_nodes/ComfyUI-Advanced-ControlNet || true


# ============================================================
# LOGIC (KEEP)
# ============================================================
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Logic.git \
    custom_nodes/ComfyUI-Logic || true


# ============================================================
# UI STACK (UNCHANGED)
# ============================================================
RUN git clone --depth 1 https://github.com/crystian/ComfyUI-Crystools.git \
    custom_nodes/ComfyUI-Crystools || true

RUN git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git \
    custom_nodes/ComfyUI-KJNodes || true

RUN git clone --depth 1 https://github.com/alexopus/ComfyUI-Image-Saver.git \
    custom_nodes/ComfyUI-Image-Saver || true

RUN git clone --depth 1 https://github.com/cubiq/ComfyUI_essentials.git \
    custom_nodes/ComfyUI_essentials || true

RUN git clone --depth 1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git \
    custom_nodes/ComfyUI-Custom-Scripts || true

RUN git clone --depth 1 https://github.com/yolain/ComfyUI-Easy-Use.git \
    custom_nodes/ComfyUI-Easy-Use || true

RUN git clone --depth 1 https://github.com/stavsap/ComfyUI-Ollama.git \
    custom_nodes/ComfyUI-Ollama || true

RUN git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git \
    custom_nodes/rgthree-comfy || true


# ============================================================
# HF DOWNLOADER (KEEP)
# ============================================================
RUN git clone --depth 1 https://github.com/if-ai/ComfyUI-IF_AI_HFDownloaderNode.git \
    custom_nodes/ComfyUI-IF_AI_HFDownloaderNode || true


# ============================================================
# PERMISSIONS
# ============================================================
RUN chown -R 42420:42420 /workspace

ENV HOME=/workspace
USER 42420:42420


# ============================================================
# START
# ============================================================
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
