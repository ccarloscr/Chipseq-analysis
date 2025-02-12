#!/usr/bin/env nextflow

nextflow.enable.dsl=2

### Default parameters

params {
    fastq_dir = "Chipseq-analysis/Fastq_files"                # Path to fastq files
    genome_index = "Chipseq-analysis/dm3/dm3_index            # Path to HISAT2 genome index
    output_dir = "Chipseq-analysis/Results"                   # Output directory
    max_mismatch = 4                                          # Maximum mapping mismatch allowed

}


process Mapping {
    tag "Mapping Process"

    ## Define input
    input:
    path fastq_file

    ## Define ouput
    output:
    path "*.bam", emit: mapped_bam

    script:
    """

    ## Define ouput directory
    output_dir_mapping="${params.output_dir}/Mapped"

    ## Run mapping script
    bash /Chipseq-analysis/Scripts/mapping.sh
        "${params.genome_index}"
        "${fastq_file}"
        "${output_dir_mapping}"
    """
}

process PostMapping {
    tag "Post-Mapping Process"

    input:
    path mapped_data from Mapping.out

    output:
    path "processed_data/"

    script:
    """
    bash post-map-process.sh
    """
}

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

