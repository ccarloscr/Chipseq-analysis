#!/bin/bash

# Variable set up
REFERENCE_GENOME="dm3/dm3_index"
FASTQ_DIR="Histone_ChIPseq/Fastq_files"
OUTPUT_DIR="Histone_ChIPseq/Mapped"

# Activate conda environment
module load anaconda
source activate chipseq_env

# Create output folder
mkdir -p $OUTPUT_DIR

# Mappinng using HISAT2
for fastq_file in $FASTQ_DIR/*.fastq; do
    # Create variable based on fastq filename
    base_name=$(basename "$fastq_file" .fastq)
    # Define output name
    output_sam="$OUTPUT_DIR/${base_name}_mapped.sam"
    # Mapping os single-end fastq files
    hisat2 -x $REFERENCE_GENOME -U $fastq_file -S $output_sam
    # Conversion of sam files into bam files
    samtools view -bS $output_sam > "$OUTPUT_DIR/${base_name}_mapped.bam"
    # Error control: check if bam file is empty
    if [[ ! -s "$output_bam" ]]; then
        echo "ERROR: BAM file is empty for $fastq_file"
        continue
    fi
    echo "Mapping for $fastq_file completed."
done
echo "All mappings completed."
