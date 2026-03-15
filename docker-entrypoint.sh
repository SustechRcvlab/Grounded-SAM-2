#!/bin/bash
# Docker entrypoint for Grounded SAM 2
# Handles environment setup and then runs the provided command

set -e

WORKDIR="/home/appuser/Grounded-SAM-2"

# Inform the user if a HuggingFace mirror is active
if [ -n "${HF_ENDPOINT}" ]; then
    echo "[INFO] Using HuggingFace mirror: ${HF_ENDPOINT}"
fi

# Verify that required checkpoint directories exist
if [ ! -d "${WORKDIR}/checkpoints" ]; then
    mkdir -p "${WORKDIR}/checkpoints"
    echo "[WARN] checkpoints/ directory was missing — created it."
    echo "[WARN] Please run: cd checkpoints && bash download_ckpts.sh"
fi

if [ ! -d "${WORKDIR}/gdino_checkpoints" ]; then
    mkdir -p "${WORKDIR}/gdino_checkpoints"
    echo "[WARN] gdino_checkpoints/ directory was missing — created it."
    echo "[WARN] Please run: cd gdino_checkpoints && bash download_ckpts.sh"
fi

# Ensure output directory exists
mkdir -p "${WORKDIR}/outputs"

cd "${WORKDIR}"

exec "$@"
