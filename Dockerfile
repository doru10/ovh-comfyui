FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# ============================================================
# System dependencies
# ============================================================
RUN apt-get update && apt-get install -y \
    git python3 python3-pip libgl1 libglib2.0-0 \
    build-essential cmake python3-dev \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# Working directory
# ============================================================
WORKDIR /workspace


# ============================================================
# PyTorch (CUDA 12.1)
# ============================================================
RUN pip install --no-cache-dir \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121


# ============================================================
# Clone ComfyUI
# ============================================================
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

RUN pip install --no-cache-dir -r requirements.txt


# ============================================================
# ALL PYTHON DEPENDENCIES (CONSOLIDATED)
# ============================================================
RUN pip install --no-cache-dir \
    numpy \
    einops \
    safetensors \
    tqdm \
    pillow \
    huggingface_hub \
    hf_transfer \
    accelerate \
    transformers \
    sentencepiece \
    protobuf \
    requests \
    aiohttp \
    psutil \
    opencv-python-headless \
    imageio \
    imageio-ffmpeg \
    av \
    onnxruntime-gpu \
    xformers \
    insightface \
    cupy-cuda12x


# ============================================================
# HuggingFace config
# ============================================================
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV HF_HOME=/workspace/.cache/huggingface
ENV TRANSFORMERS_CACHE=/workspace/.cache/huggingface


# ============================================================
# CORE
# ============================================================
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
    custom_nodes/ComfyUI-Manager \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt


# ============================================================
# WAN / VIDEO STACK
# ============================================================
RUN git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git \
    custom_nodes/ComfyUI-WanVideoWrapper \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt

RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git \
    custom_nodes/ComfyUI-VideoHelperSuite \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt

RUN git clone https://github.com/naxci1/ComfyUI-FlashVSR_Stable.git \
    custom_nodes/ComfyUI-FlashVSR

RUN git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git \
    custom_nodes/ComfyUI-Frame-Interpolation \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Frame-Interpolation/requirements-no-cupy.txt


# ============================================================
# MODEL / LOADER TOOLS
# ============================================================
RUN git clone https://github.com/willmiao/ComfyUI-Lora-Manager.git \
    custom_nodes/ComfyUI-Lora-Manager \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Lora-Manager/requirements.txt

RUN git clone https://github.com/civitai/civitai_comfy_nodes.git \
    custom_nodes/civitai_comfy_nodes

RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git \
    custom_nodes/ComfyUI-Impact-Pack \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Impact-Pack/requirements.txt

RUN git clone https://github.com/WASasquatch/was-node-suite-comfyui.git \
    custom_nodes/was-node-suite-comfyui \
 && pip install --no-cache-dir -r custom_nodes/was-node-suite-comfyui/requirements.txt

RUN git clone https://github.com/chflame163/ComfyUI_LayerStyle.git \
    custom_nodes/ComfyUI_LayerStyle \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI_LayerStyle/requirements.txt


# ============================================================
# IMAGE / CONTROL / STYLE
# ============================================================
RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git \
    custom_nodes/ComfyUI_IPAdapter_plus

RUN mkdir -p models/ipadapter models/clip_vision

RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git \
    custom_nodes/comfyui_controlnet_aux \
 && pip install --no-cache-dir -r custom_nodes/comfyui_controlnet_aux/requirements.txt

RUN git clone https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git \
    custom_nodes/ComfyUI-Advanced-ControlNet \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Advanced-ControlNet/requirements.txt || true

RUN git clone https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait.git \
    custom_nodes/ComfyUI-AdvancedLivePortrait \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-AdvancedLivePortrait/requirements.txt || true


# ============================================================
# EXTRA NODES
# ============================================================
RUN git clone https://github.com/crystian/ComfyUI-Crystools.git \
    custom_nodes/ComfyUI-Crystools \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Crystools/requirements.txt

RUN git clone https://github.com/city96/ComfyUI-GGUF.git \
    custom_nodes/ComfyUI-GGUF \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-GGUF/requirements.txt || true

RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git \
    custom_nodes/ComfyUI-KJNodes \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-KJNodes/requirements.txt

RUN git clone https://github.com/alexopus/ComfyUI-Image-Saver.git \
    custom_nodes/ComfyUI-Image-Saver

RUN git clone https://github.com/cubiq/ComfyUI_essentials.git \
    custom_nodes/ComfyUI_essentials \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI_essentials/requirements.txt

RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git \
    custom_nodes/ComfyUI-Custom-Scripts

RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git \
    custom_nodes/ComfyUI-Easy-Use \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Easy-Use/requirements.txt

RUN git clone https://github.com/stavsap/ComfyUI-Ollama.git \
    custom_nodes/ComfyUI-Ollama \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-Ollama/requirements.txt

RUN git clone https://github.com/rgthree/rgthree-comfy.git \
    custom_nodes/rgthree-comfy

RUN git clone https://github.com/if-ai/ComfyUI-IF_AI_HFDownloaderNode.git \
    custom_nodes/ComfyUI-IF_AI_HFDownloaderNode \
 && pip install --no-cache-dir -r custom_nodes/ComfyUI-IF_AI_HFDownloaderNode/requirements.txt || true


# ============================================================
# Permissions
# ============================================================
RUN chown -R 42420:42420 /workspace

ENV HOME=/workspace

USER 42420:42420


# ============================================================
# START
# ============================================================
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
