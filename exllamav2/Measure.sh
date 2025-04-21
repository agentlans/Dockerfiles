# Run just the measurement pass on a model, clearing the working directory first:

INPUT_DIR=/workspace/input-model
WORK_DIR=$INPUT_DIR/EXL2/Work
OUTPUT_DIR=$INPUT_DIR/EXL2/Output

mkdir -p $WORK_DIR $OUTPUT_DIR

python /workspace/exllamav2/convert.py \
    -i $INPUT_DIR \
    -o $WORK_DIR \
    -om $OUTPUT_DIR/measurement.json
