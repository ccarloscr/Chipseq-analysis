#!/bin/bash

# Author: Carlos Camilleri-Robles
# Contact: carloscamilleri@hotmail.com
# Version: updated 05-03-2025
# This script uses HISAT2 to map single-end reads to dm3

set -e

## Check that conda encironment is activated
source ~/miniconda3/etc/profile.d/conda.sh
conda activate workplace || { echo "Error: Conda environment not activated!"; exit 1; }
echo "Using HISAT2 from: $(which hisat2)"

## Variable set up
FASTQ_FILE=$1
REFERENCE_GENOME=$2
OUTPUT_DIR=$3

## Check if the input fastq file is correct
echo "Checking file: $FASTQ_FILE"
if [[ ! -f $FASTQ_FILE ]]; then
    echo "Error: The input file $FASTQ_FILE does not exist." >&2
    exit 1
fi

## Check if the reference genome is available
echo "Checking refrence genome index: $REFERENCE_GENOME"
if [[ ! -f "${REFERENCE_GENOME}/dm3_index.1.ht2" ]]; then
    echo "Error: reference genome index files are not available." >&2
    exit 1
fi


# Create variable based on fastq filename
base_name=$(basename "$FASTQ_FILE" .fastq)
    
# Define output
output_sam="$OUTPUT_DIR/${base_name}_mapped.sam"
output_bam="$OUTPUT_DIR/${base_name}_mapped.bam"
    
# Mapping of single-end fastq files
hisat2 -x "$REFERENCE_GENOME" -U "$FASTQ_FILE" -S "$output_sam"
    
# Conversion of sam files into bam files
samtools view -bS "$output_sam" > "$output_bam"
    
# Check if bam file is empty
if [[ ! -s "$output_bam" ]]; then
    echo "Error: BAM file is empty for $FASTQ_FILE." >&2
    exit 1  
fi
    
echo "Mapping for $FASTQ_FILE completed." >&2
