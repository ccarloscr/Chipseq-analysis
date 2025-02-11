#!/bin/bash

# Author: Carlos Camilleri-Robles
# Contact: carloscamilleri@hotmail.com
# This script uses samtools to filter, sort and index the resulting .bam files of an alignment

set -e

## Variable set up
INPUT_DIR="Chipseq-analysis/Mapped"
FILTERED_DIR="Chipseq-analysis/Mapped/Filtered"
SORTED_DIR="Chipseq-analysis/Mapped/Sorted"
MAX_MISMATCH="4"  # Only works for up to 9 mismatches


## Activate conda environment
module load anaconda
source activate chipseq_env


## Create output folder
mkdir -p $FILTERED_DIR
mkdir -p $SORTED_DIR


## Processing of mapped .bam files

for bam_file in $INPUT_DIR/*.bam; do

    # Create variable based on mapped bam filename
    base_name=$(basename "$bam_file" _mapped.bam)
    
    # Define output names
    filtered_bam="$FILTERED_DIR/${base_name}_filtered.bam"
    sorted_bam="$SORTED_DIR/${base_name}_sorted.bam"
    
    # Filter out reads containing less than $MAX_MISMATCH mismatches
    echo "Filtering $bam_file..."
    if !  samtools view -h "$bam_file" | grep -E "^@|NM:i:[0-$MAX_MISMATCH]" | samtools view -bS - > "$filtered_bam"; then          
          echo "Error filtering $bam_file" >&2
    else
          echo "Filtering of $bam_file complete."
    fi
    
    # Sorting of bam files
    echo "Sorting $filtered_bam..."
    if !  samtools sort -o "$sorted_bam" "$filtered_bam"; then
          echo "Error sorting $bam_file" >&2
    else
          echo "Sorting of $bam_file complete."
    fi

    # Indexing of bam files
    echo "Indexing $filtered_bam..."
    if !  samtools index "$sorted_bam"; then
          echo "Error indexing $bam_file" >&2
    else
          echo "Indexing of $bam_file complete."
    fi

    echo "Processing of $bam_file complete"
done

