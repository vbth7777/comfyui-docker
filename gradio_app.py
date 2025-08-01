
import gradio as gr
import subprocess
import threading
import time
import os

def run_comfyui():
    os.chdir('/comfyui')
    p = subprocess.Popen(['python3', 'main.py', '--listen', '0.0.0.0'])
    return p

def get_comfyui_url():
    return "http://127.0.0.1:8188"

def start_gradio():
    p = run_comfyui()
    time.sleep(15)  # Wait for ComfyUI to start
    
    with gr.Blocks() as demo:
        gr.Markdown("# ComfyUI")
        gr.HTML(f'<iframe src="{get_comfyui_url()}" width="100%" height="800px"></iframe>')

    demo.launch(share=True)

if __name__ == "__main__":
    start_gradio()
