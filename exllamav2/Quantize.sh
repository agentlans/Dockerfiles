
INPUT_DIR=/workspace/input-model
BITS=$1

WORK_DIR=$INPUT_DIR/EXL2/Work
OUTPUT_DIR=$INPUT_DIR/EXL2/Output

python /workspace/exllamav2/convert.py \
    -i $INPUT_DIR \
    -o $WORK_DIR \
    -nr \
    -m $OUTPUT_DIR/measurement.json \
    -cf $OUTPUT_DIR/${BITS}bpw/ \
    -b $BITS
