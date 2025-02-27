#!/bin/bash

# Author: Carlos Camilleri-Robles
# Contact: carloscamilleri@hotmail.com
# Version: updated 24-02-2025
# This script uses HISAT2 to map single-end reads to dm3

set -e


## Variable set up
REFERENCE_GENOME=$1
FASTQ_FILE=$(readlink -f "$2")
OUTPUT_DIR=$3


## Check if the reference genome is available
if [[ ! -f "${REFERENCE_GENOME}/dm3_index.1.ht2" ]]; then
    echo "Error: reference genome index files are not available." >&2
    exit 1
fi


## Check if the input directory exists
if [[ ! -f "$FASTQ_FILE" ]]; then
    echo "Error: The input file $FASTQ_FILE does not exist." >&2
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
