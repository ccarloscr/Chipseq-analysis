#!/bin/bash

## Comments
## This peak calling is optimized for reads with no strand information
## For strand-specific reads, remove the --nomodel and --extsize options of the macs2 callpeak

# Variable set up
INPUT_DIR="Histone_ChIPseq/Mapped/Sorted"
OUTPUT_DIR="Histone_ChIPseq/Peaks"
INPUT_NAME=""      # Name of input file (no antibody)
EXP_NAME=""        # Name of experimental file (antibody)
EXTSIZE="150"      # Average fragment length (i.e. minimal peak size)



mkdir -p $OUTPUT_DIR

# Peak calling using MACS2
for bam_file in $INPUT_DIR/*.bam; do
    # Create variable name
    base_name=$(basename "$fastq_file" _sorted.bam)
    # Define output name
    output_sam="$OUTPUT_DIR/${base_name}_mapped.sam"
    # Peak calling
    macs2 callpeak -t bam_file -c ??? -f BAM -g dm --outdir $OUTPUT_DIR -n ?? --nomodel --extsize $EXTSIZE

