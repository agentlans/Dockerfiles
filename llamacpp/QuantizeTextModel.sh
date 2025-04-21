#!/bin/bash

set -e

# --- Configuration ---
MODEL_DIR="/models/input-model/GGUF"
MODEL_FILE="$MODEL_DIR/model.gguf"
IMATRIX_FILE="$MODEL_DIR/imatrix.dat"
TRAINING_DATA="/training-data"
TMP_TRAINING="/tmp/training.txt"

# --- Main Script ---

if [ $# -eq 0 ]; then
    echo "Usage: $0 <QUANT_TYPE1> [QUANT_TYPE2 ...]"
    exit 1
fi

mkdir -p "$MODEL_DIR"

# Convert model if needed
if [ ! -f "$MODEL_FILE" ]; then
    echo "Model file not found, converting..."
    python3 convert_hf_to_gguf.py --outfile "$MODEL_FILE" /models/input-model
else
    echo "Model file exists, skipping conversion."
fi

# Prepare training file
if [ -d "$TRAINING_DATA" ]; then
    cat "$TRAINING_DATA"/* > "$TMP_TRAINING" 2>/dev/null || true
    if [ ! -s "$TMP_TRAINING" ]; then
        rm -f "$TMP_TRAINING"
    fi
else
    rm -f "$TMP_TRAINING"
fi

# Generate imatrix if needed
IMATRIX_GENERATED=1
if [ -s "$TMP_TRAINING" ]; then
    if [ ! -f "$IMATRIX_FILE" ]; then
        echo "Non-empty training data found, generating imatrix..."
        ./build/bin/llama-imatrix -m "$MODEL_FILE" -f "$TMP_TRAINING" -o "$IMATRIX_FILE"
    else
        echo "imatrix.dat already exists, skipping imatrix generation."
    fi
    IMATRIX_GENERATED=0
fi

# Quantize for each QUANT_TYPE
for QUANT_TYPE in "$@"; do
    QUANT_FILE="$MODEL_DIR/${QUANT_TYPE}.gguf"
    if [ -f "$QUANT_FILE" ]; then
        echo "Quantized file '$QUANT_FILE' already exists. Skipping."
        continue
    fi

    if [ "$IMATRIX_GENERATED" -eq 0 ]; then
        echo "Quantizing with imatrix for type '$QUANT_TYPE'..."
        ./build/bin/llama-quantize --imatrix "$IMATRIX_FILE" "$MODEL_FILE" "$QUANT_FILE" "$QUANT_TYPE"
    else
        echo "Quantizing directly (no training data) for type '$QUANT_TYPE'..."
        ./build/bin/llama-quantize "$MODEL_FILE" "$QUANT_FILE" "$QUANT_TYPE"
    fi
done

echo "Done."

