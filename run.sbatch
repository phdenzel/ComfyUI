#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --job-name=comfyUI
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --gres=gpu:h100pcie:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=128G
#SBATCH --nodelist=sanjose
#SBATCH --account=cai_teaching
#SBATCH --partition=teaching
#SBATCH --output=/cluster/projects/2025_image_tools/logs/%x.id%j.%N.sbatch.out
#SBATCH --error=/cluster/projects/2025_image_tools/logs/%x.id%j.%N.sbatch.err
# #SBATCH --signal=B:SIGUSR1@900

usage() {
    cat <<EOF
Usage: $0 [-p|--port <in>] [-h|--help]

        This is a SLURM batch script for deploying comfyUI.

    Options:
        -p, --port             Port for the server.
        -h, --help             Print this message.
EOF
}


# Defaults
CU_MODULE=cuda/12.8.0
PY_MODULE=python/3.13.2
UV_MODULE=uv/0.6.12
ENV_NAME="comfy-ui"  # define python virtualenv name
PKG_DIR="/cluster/projects/2025_image_tools/comfyUI"
PORT="8598"

# Parse args
OPTS=$(getopt -o p:h --long help,port: -- "$@")
if [ $? != 0 ] ; then
    echo "[`date '+%Y-%m-%d %T.%3N'`][SLURM] - Failed to parse arguments." >&2
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            shift
            ;;
    esac
done
# Required arguments
if [[ $PORT -ge 8500 && $PORT -le 9200 ]]; then
    echo "Port $PORT is within the allowed range."
else
    echo "Port $PORT is outside the allowed range."
fi

# load modules
module load "$CU_MODULE"
module load "$PY_MODULE"
VENV="$ENV_NAME" module load "$UV_MODULE"
cd $PKG_DIR
[ ! -d "$PKG_DIR/custom_nodes/comfyui-manager" ] && git clone https://github.com/ltdrdata/ComfyUI-Manager.git $PKG_DIR/custom_nodes/comfyui-manager
[ ! -d "$PKG_DIR/custom_nodes/comfyui-impact-pack" ] && git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git $PKG_DIR/custom_nodes/comfyui-impact-pack
[ ! -d "$PKG_DIR/custom_nodes/comfyui-impact-subpack" ] && git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git $PKG_DIR/custom_nodes/comfyui-impact-subpack
[ ! -d "$PKG_DIR/custom_nodes/ComfyUI-Easy-Use" ] && git clone https://github.com/yolain/ComfyUI-Easy-Use.git $PKG_DIR/custom_nodes/ComfyUI-Easy-Use
[ ! -d "$PKG_DIR/custom_nodes/ComfyUI-ReActor" ] && git clone https://github.com/Gourieff/ComfyUI-ReActor.git $PKG_DIR/custom_nodes/ComfyUI-ReActor
[ ! -d "$PKG_DIR/custom_nodes/comfyui-comfyui-yolo" ] && git clone https://github.com/kadirnar/ComfyUI-YOLO.git $PKG_DIR/custom_nodes/comfyui-yolo
[ ! -d "$PKG_DIR/custom_nodes/comfyui-comfyui-transformers" ] && git clone https://github.com/kadirnar/ComfyUI-Transformers.git $PKG_DIR/custom_nodes/comfyui-transformers
[ ! -d "$PKG_DIR/custom_nodes/ComfyUI-VideoHelperSuite" ] && git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git $PKG_DIR/custom_nodes/ComfyUI-VideoHelperSuite
[ ! -d "$PKG_DIR/custom_nodes/was-node-suite-comfyui" ] && git clone https://github.com/ltdrdata/was-node-suite-comfyui.git $PKG_DIR/custom_nodes/was-node-suite-comfyui
[ ! -d "$PKG_DIR/custom_nodes/ComfyUI_Sonic" ] && git clone https://github.com/smthemex/ComfyUI_Sonic.git $PKG_DIR/custom_nodes/ComfyUI_Sonic
[ ! -d "$PKG_DIR/custom_nodes/VibeVoice-ComfyUI" ] && git clone https://github.com/Enemyx-net/VibeVoice-ComfyUI.git $PKG_DIR/custom_nodes/VibeVoice-ComfyUI
[ ! -d "$PKG_DIR/custom_nodes/comfyui-kokoro" ] && git clone https://github.com/stavsap/comfyui-kokoro.git $PKG_DIR/custom_nodes/comfyui-kokoro
[ ! -d "$PKG_DIR/custom_nodes/rgthree-comfy" ] && git clone https://github.com/rgthree/rgthree-comfy $PKG_DIR/custom_nodes/rgthree-comfy
[ ! -d "$PKG_DIR/custom_nodes/ComfyUI_UltimateSDUpscale" ] && git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git --recursive $PKG_DIR/custom_nodes/ComfyUI_UltimateSDUpscale
[ ! -d "$PKG_DIR/custom_nodes/masquerade-nodes-comfyui" ] && git clone https://github.com/BadCafeCode/masquerade-nodes-comfyui.git $PKG_DIR/custom_nodes/masquerade-nodes-comfyui
[ ! -d "$PKG_DIR/custom_nodes/ComfyUI-Flowty-LDSR" ] && git clone https://github.com/flowtyone/ComfyUI-Flowty-LDSR.git $PKG_DIR/custom_nodes/ComfyUI-Flowty-LDSR
# [ ! -d "$PKG_DIR/custom_nodes/" ] && git clone  $PKG_DIR/custom_nodes/
# [ ! -d "$PKG_DIR/custom_nodes/" ] && git clone  $PKG_DIR/custom_nodes/
uv sync

# Run webui
echo "[`date '+%Y-%m-%d %T.%3N'`][SLURM] - `hostname`"
uv run python $PKG_DIR/main.py --listen 0.0.0.0 --port $PORT --multi-user
echo "[`date '+%Y-%m-%d %T.%3N'`][SLURM] - Shutdown"
