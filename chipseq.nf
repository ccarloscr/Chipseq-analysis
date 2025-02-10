#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process Mapping {
    tag "Mapping Process"
    
    input:
    path fastq_files from "/Histone"

    output:
    path "mapped_data/" 

    script:
    """
    bash mapping.sh
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

