#!/bin/bash

# Author: Carlos Camilleri-Robles
# Contact: carloscamilleri@hotmail.com
# Version:
# This script uses samtools to filter, sort and index the resulting .bam files of an alignment

set -e

## Variable set up
INPUT_BAM="$1"
OUTPUT_DIR="$2"
MAX_MISMATCH="$3"

## Get basename of input .bam files
base_name=$(basename "$INPUT_BAM" .bam)
base_name=${base_name%_mapped}

## Define outputs
filtered_bam="$OUTPUT_DIR/${base_name}_filtered.bam"
sorted_bam="$OUTPUT_DIR/${base_name}_sorted.bam"

## Filter reads with less mismatches than max set
echo "Filtering $INPUT_BAM..."
if ! samtools view -h -b -q $MAX_MISMATCH "$INPUT_BAM" > "$filtered_bam"; then
    echo "Error filtering $INPUT_BAM" >&2
    exit 1
fi

## Sort filtered bam files
echo "Sorting $filtered_bam..."
if ! samtools sort -o "$sorted_bam" "$filtered_bam"; then
    echo "Error sorting $filtered_bam" >&2
    exit 1
fi

## Indexing sorted bam files
echo "Indexing $sorted_bam..."
if ! samtools index "$sorted_bam"; then
    echo "Error indexing $sorted_bam" >&2
    exit 1
fi

echo "Processing of $INPUT_BAM done."
