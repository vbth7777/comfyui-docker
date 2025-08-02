#!/bin/bash

# Update and install dependencies
apt-get update && \
    apt-get install -y \
    git \
    python3-pip \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Set up the ComfyUI directory
mkdir -p /comfyui
cd /comfyui

# Clone the ComfyUI repository
git clone https://github.com/comfyanonymous/ComfyUI.git .

# Install Python dependencies
pip install --no-cache-dir -r requirements.txt
pip install --no-cache-dir gradio requests

# Install ComfyUI-Manager
cd custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ..

# Install huggingface-cli
pip install --no-cache-dir huggingface_hub

# Create directories for models
mkdir -p /comfyui/models/vae && \
    mkdir -p /comfyui/models/text_encoders && \
    mkdir -p /comfyui/models/diffusion_models

# Download models using huggingface-cli
if [ -z "$1" ]; then
  echo "Hugging Face token not provided. Skipping model download."
  echo "To download models, run the script with your token: ./setup.sh <your_hf_token>"
else
  echo "Hugging Face token provided. Downloading models..."
  export HF_TOKEN=$1
  huggingface-cli download Comfy-Org/Lumina_Image_2.0_Repackaged split_files/vae/ae.safetensors --local-dir /comfyui --local-dir-use-symlinks False && mv /comfyui/split_files/vae/ae.safetensors /comfyui/models/vae/ae.safetensors
  huggingface-cli download comfyanonymous/flux_text_encoders clip_l.safetensors --local-dir /comfyui --local-dir-use-symlinks False && mv /comfyui/clip_l.safetensors /comfyui/models/text_encoders/clip_l.safetensors
  huggingface-cli download comfyanonymous/flux_text_encoders t5xxl_fp8_e4m3fn_scaled.safetensors --local-dir /comfyui --local-dir-use-symlinks False && mv /comfyui/t5xxl_fp8_e4m3fn_scaled.safetensors /comfyui/models/text_encoders/t5xxl_fp8_e4m3fn_scaled.safetensors
  huggingface-cli download comfyanonymous/flux_text_encoders t5xxl_fp16.safetensors --local-dir /comfyui --local-dir-use-symlinks False && mv /comfyui/t5xxl_fp16.safetensors /comfyui/models/text_encoders/t5xxl_fp16.safetensors
  huggingface-cli download Comfy-Org/flux1-kontext-dev_ComfyUI split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors --local-dir /comfyui --local-dir-use-symlinks False && mv /comfyui/split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors /comfyui/models/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors
  huggingface-cli download black-forest-labs/FLUX.1-Fill-dev flux1-fill-dev.safetensors --local-dir /comfyui --local-dir-use-symlinks False && mv /comfyui/flux1-fill-dev.safetensors /comfyui/models/diffusion_models/flux1-fill-dev.safetensors
fi

echo "Setup complete. To run the application, you can use the following command:"
echo "python3 /comfyui/gradio_app.py"
