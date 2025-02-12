#!/usr/bin/env nextflow

nextflow.enable.dsl=2



### Default parameters

params {
    fastq_dir = "Chipseq-analysis/Fastq_files"                # Path to fastq files
    genome_index = "Chipseq-analysis/dm3/dm3_index            # Path to HISAT2 genome index
    output_dir = "Chipseq-analysis/Results"                   # Output directory
    max_mismatch = 4                                          # Maximum mapping mismatch allowed

}



### Define channel containing fastq files

Channel
    .fromPath("${params.fastq_dir}/*.fastq")
    .set { fastq_channel }



### Process 1: mapping using HISAT2

process Mapping {
    tag "Mapping Process"

    ## Define input: fastq elements from the fastq_channel defined previously
    input:
    path fastq_file

    ## Capture output .bam files into mapped_bam channel
    output:
    path "*.bam", emit: mapped_bam

    script:
    """
    ## Define output directory
    output_dir_mapping="${params.output_dir}/Mapped"
    mkdir -p "\$output_dir_mapping"

    ## Run mapping script
    bash /Chipseq-analysis/Scripts/mapping.sh
        "${params.genome_index}"        # Genome index directory
        "${fastq_file}"                 # Input fastq files from fastq_channel
        "${output_dir_mapping}"         # Output directory
    """
}



### Process 2: Filtering, sorting and indexing of .bam files

process PostMapping {
    tag "Post-Mapping Process"

    # Define input: each .bam file from the mapped_bam channel
    input:
    path bam_file

    ## Capture output .sorted.bam files into sorted_bam channel
    output:
    path "*.sorted.bam", emit: sorted_bam

    script:
    """
    ## Define output directories
    filtered_dir = "${params.output_dir}/Mapped/Filtered"
    sorted_dir = "${params.output_dir}/Mapped/Sorted"
    mkdir -p "\$filtered_dir"
    mkdir -p "\$sorted_dir"

    ## Run processing script
    bash post-map-process.sh
    """
}



### Process 3: Peak calling using MACS2

process PeakCalling {
    tag "Peak-Calling Process"

    input:
    path processed_data from PostMapping.out

    output:
    path "peaks/"

    script:
    """
    bash peak-calling.sh
    """
}

workflow {
    Mapping()
    PostMapping()
    PeakCalling()
}

