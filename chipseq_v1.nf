#!/usr/bin/env nextflow

nextflow.enable.dsl=2



// Default parameters

params {
    fastq_dir = "Chipseq-analysis/Fastq_files"                // Path to fastq files
    genome_index = "Chipseq-analysis/dm3/dm3_index"           // Path to genome index
    metadata = "Chipseq-analysis/metadata.csv"                // Path to metadata file
    output_dir = "Chipseq-analysis/Results"                   // Output directory
    max_mismatch = 4                                          // Maximum mapping mismatch allowed
    ext_size = 150                                            // Average fragment length; i.e. maximum peak size
}



// Define channel containing fastq files

Channel
    .fromPath("${params.fastq_dir}/*.fastq")
    .set { fastq_channel }



// Process 1: mapping using HISAT2

process Mapping {
    tag "Mapping Process"

    // Define input: fastq elements from the fastq_channel defined previously
    input:
    path genome_index
    path fastq_file

    // Capture output .bam files into mapped_bam channel
    output:
    path "*.bam", emit: mapped_bam

    script:
    output_dir_mapping="${params.output_dir}/Mapped"
    """
    bash /Chipseq-analysis/Scripts/mapping.sh
        "${genome_index}"               // Genome index directory
        "${fastq_file}"                 // Input fastq files from fastq_channel
        "${output_dir_mapping}"         // Output directory
    """
}



// Process 2: Filtering, sorting and indexing of .bam files

process PostMapping {
    tag "Post-Mapping Process"

    // Publish all sorted bam files into a common directory
    publishDir "${params.output_dir}/Sorted",
        mode: 'copy',
        pattern: '*.bam',
        overwrite: true

    // Define input: each .bam file from the mapped_bam channel and the parameter defined as param.max_mismatch
    input:
    path bam_file
    val max_mismatch

    // Define output directories
    def filtered_dir = "${params.output_dir}/Filtered"
    def sorted_dir = "${params.output_dir}/Sorted"

    // Pass sorted .bam files
    output:
    path "${sorted_dir}/*.bam", emit: sorted_bam

    // Run processing script
    script:
    """
    bash /Chipseq-analysis/Scripts/Post-map-process.sh
        "${bam_file}"                 // Input files from the mapped_bam channel
        "${filtered_dir}"             // Filtered .bam files directory
        "${sorted_dir}"               // Sorted .bam files directory
        "${max_mismatch}"             // Maximum number of mismatches allowed
    """
}



// Process 3: Peak calling using MACS2

process PeakCalling {
    tag "Peak-Calling Process"

    // Define input: each .bam file from the sorted_bam channel
    input:
    path metadata
    val ext_size
    path sorted_dir

    // Define output directory
    def peaks_dir = "${params.output_dir}/Peak_calling"

    // Define output directory and capture output .narrowPeak files into narrow_peaks channel
    output:
    path "${peaks_dir}/*.narrowPeak", emit: narrow_peaks

    // Run peak calling script
    script:
    """
    bash /Chipseq-analysis/Scripts/Peak-calling.sh
        "${metadata}"                 // Metadata file
        "${ext_size}"                 // Average fragment length (i.e. minimal peak size)
        "${sorted_dir}"               // Bam files used as input
        "${peaks_dir}"                // Output directory
    """
}

workflow {
    mapped_bam = Mapping(params.genome_index, fastq_channel)
    sorted_bam = PostMapping(mapped_bam, params.max_mismatch)
    PeakCalling(file(params.metadata), params.ext_size, sorted_bam.collect())
}

