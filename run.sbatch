#!/bin/bash
#SBATCH --time=04:00:00
#SBATCH --job-name=comfyUI
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=128G
#SBATCH --account=cai_ivs
#SBATCH --partition=gpu_top
#SBATCH --mail-user=denp@zhaw.ch
#SBATCH --output=/cluster/home/denp/logs/%x.id%j.%N.sbatch.out
#SBATCH --error=/cluster/home/denp/logs/%x.id%j.%N.sbatch.err
# #SBATCH --signal=B:SIGUSR1@900

# Defaults
CU_MODULE=cuda/12.8.0
PY_MODULE=python/3.13.2
UV_MODULE=uv/0.6.12
ENV_NAME="comfy-ui"  # define python virtualenv name
PKG_DIR="/cluster/home/denp/comfyUI"
PORT=8623

# load modules
module load "$CU_MODULE"
module load "$PY_MODULE"
VENV="$ENV_NAME" module load "$UV_MODULE"
cd $PKG_DIR
[ ! -d "$PKG_DIR/custom_nodes/comfyui-manager" ] && git clone https://github.com/ltdrdata/ComfyUI-Manager.git $PKG_DIR/custom_nodes/comfyui-manager
[ ! -d "$PKG_DIR/custom_nodes/comfyui-impact-pack" ] && git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git $PKG_DIR/custom_nodes/comfyui-impact-pack
[ ! -d "$PKG_DIR/custom_nodes/comfyui-impact-subpack" ] && git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git $PKG_DIR/custom_nodes/comfyui-impact-subpack
[ ! -d "$PKG_DIR/custom_nodes/comfyui-comfyui-yolo" ] && git clone https://github.com/kadirnar/ComfyUI-YOLO.git $PKG_DIR/custom_nodes/comfyui-yolo
[ ! -d "$PKG_DIR/custom_nodes/comfyui-comfyui-transformers" ] && git clone https://github.com/kadirnar/ComfyUI-Transformers.git $PKG_DIR/custom_nodes/comfyui-transformers
uv sync

# Run webui
echo "[`date '+%Y-%m-%d %T.%3N'`][SLURM] - `hostname`"
uv run python $PKG_DIR/main.py --listen 0.0.0.0 --port $PORT --multi-user
echo "[`date '+%Y-%m-%d %T.%3N'`][SLURM] - Shutdown"
