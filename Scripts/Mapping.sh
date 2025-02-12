#!/bin/bash

# Author: Carlos Camilleri-Robles
# Contact: carloscamilleri@hotmail.com
# Version: updated 12-02-2025
# This script uses HISAT2 to map single-end reads to dm3

set -e


## Variable set up
REFERENCE_GENOME=$1
FASTQ_DIR=$2
OUTPUT_DIR=$3


# Create directories
mkdir -p "$OUTPUT_DIR"


## Check if the reference genome is available
if [[ ! -f "${REFERENCE_GENOME}.1.ht2" ]]; then
    echo "Error: reference genome index files are not available." >&2
    exit 1
fi


## Check if the input directory exists
if [[ ! -d "$FASTQ_DIR" ]]; then
    echo "Error: The input directory "$FASTQ_DIR" does not exist." >&2
    exit 1
fi


## Mapping using HISAT2
for fastq_file in "$FASTQ_DIR"/*.fastq; do

    # Create variable based on fastq filename
    base_name=$(basename "$fastq_file" .fastq)
    
    # Define output
    output_sam="$OUTPUT_DIR/${base_name}_mapped.sam"
    output_bam="$OUTPUT_DIR/${base_name}_mapped.bam"
    
    # Mapping of single-end fastq files
    hisat2 -x "$REFERENCE_GENOME" -U "$fastq_file" -S "$output_sam"
    
    # Conversion of sam files into bam files
    samtools view -bS "$output_sam" > "$output_bam"
    
    # Check if bam file is empty
    if [[ ! -s "$output_bam"]]; then
        echo "Error: BAM file is empty for "$fastq_file"." >&2
        continue  
    fi
    
    echo "Mapping for "$fastq_file" completed." >&2
done

echo "All mappings completed."
