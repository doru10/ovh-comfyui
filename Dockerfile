FROM ghcr.io/ai-dock/comfyui:latest-cuda

# Switch to root to fix OVH permissions
USER root
RUN mkdir -p /workspace && chown -R 42420:42420 /workspace /opt

# Switch back to the mandatory OVH user
USER 42420:42420
ENV HOME=/workspace
