# Use an NVIDIA CUDA base image
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    python3-pip \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Set up the ComfyUI directory
WORKDIR /comfyui

# Clone the ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gradio requests

# Install ComfyUI-Manager
RUN cd custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Install huggingface hub
RUN pip install --no-cache-dir huggingface_hub

# Add build-time argument for Hugging Face token
ARG HF_TOKEN

# Create directories for models
RUN mkdir -p /comfyui/models/vae && \
    mkdir -p /comfyui/models/text_encoders && \
    mkdir -p /comfyui/models/diffusion_models

# Download models using huggingface-cli
RUN hf download Comfy-Org/Lumina_Image_2.0_Repackaged ae.safetensors --local-dir /comfyui/models/vae 
RUN hf download comfyanonymous/flux_text_encoders clip_l.safetensors --local-dir /comfyui/models/text_encoders 
RUN hf download comfyanonymous/flux_text_encoders t5xxl_fp8_e4m3fn_scaled.safetensors --local-dir /comfyui/models/text_encoders 
RUN hf download comfyanonymous/flux_text_encoders t5xxl_fp16.safetensors --local-dir /comfyui/models/text_encoders 
RUN hf download Comfy-Org/flux1-kontext-dev_ComfyUI flux1-dev-kontext_fp8_scaled.safetensors --local-dir /comfyui/models/diffusion_models 
RUN hf download black-forest-labs/FLUX.1-Fill-dev flux1-fill-dev.safetensors --local-dir /comfyui/models/diffusion_models 


COPY gradio_app.py /comfyui/

# Expose the default ComfyUI port
EXPOSE 8188

# Define the entrypoint
CMD ["python3", "/comfyui/gradio_app.py"]
