#!/bin/bash

## Comments
## This peak calling is optimized for reads with no strand information
## For strand-specific reads, remove the --nomodel and --extsize options of the macs2 callpeak

set -e

## Variable set up
METADATA_FILE="$1"
EXTSIZE="$2"
INPUT_DIR="$3"
OUTPUT_DIR="$4"


## Ensure metadata file exists
if [[ ! -f "$METADATA_FILE" ]]; then
    echo "Error: Metadata file $METADATA_FILE not found." >&2
    exit 1
fi


## Create directories
mkdir -p "$OUTPUT_DIR"


## Read the first 5 columns of the metadata file
IFS=$',' tail -n +2 "$METADATA_FILE" | while read -r INPUT_NAME EXP_NAME ANTIBODY CONDITION REP _; do
    INPUT_BAM="$INPUT_DIR/${INPUT_NAME}_sorted.bam"
    EXP_BAM="$INPUT_DIR/${EXP_NAME}_sorted.bam"
    OUTPUT_NAME="${ANTIBODY}_${CONDITION}_${REP}"

    # Verify if the input file exists
    if [[ ! -f "$INPUT_BAM" ]]; then
        echo "Error: Input $INPUT_BAM not found" >&2
        continue
    fi

    # Verify if the experimental chipseq file exists
    if [[ ! -f "$EXP_BAM" ]]; then
        echo "Error: Experimental Chip-seq $EXP_BAM not found" >&2
        continue
    fi

    # Peak calling using MACS2
    macs2 callpeak -t "$EXP_BAM" -c "$INPUT_BAM" -f BAM -g dm --outdir "$OUTPUT_DIR" -n "$OUTPUT_NAME" --nomodel --extsize "$EXTSIZE"
    echo "Peak calling done for: $EXP_NAME vs $INPUT_NAME"

done

echo "Peak calling complete for ${METADATA_FILE}."

