#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Default parameters
params.scripts_dir = "/home/DDGcarlos/Chipseq-analysis/Scripts"
params.fastq_dir = "/home/DDGcarlos/Chipseq-analysis/Fastq_files"
params.genome_index = "/home/DDGcarlos/Chipseq-analysis/Genomes/dm3"
params.genome_index_base = "/home/DDGcarlos/Chipseq-analysis/Genomes/dm3/dm3_index"
params.metadata = "/home/DDGcarlos/Chipseq-analysis/metadata.csv"
params.output_dir = "/home/DDGcarlos/Chipseq-analysis/Results"
params.max_mismatch = 4    // Maximum mismatch base pairs allowed per alignment
params.ext_size = 150    // Average fragment length; i.e. maximum peak size


// Process 1: mapping using HISAT2
process Mapping {
    tag "Mapping Process"

    input:
    path fastq_files
    path genome_index_files

    output:
    path "*.bam", emit: mapped_bam

    script:
    def output_dir_mapping="${params.output_dir}/Mapped"
    """
    mkdir -p ${output_dir_mapping}
    echo "Fastq file received: ${fastq_files}"
    echo "Using index base: ${params.genome_index_base}"
    bash "${params.scripts_dir}/Mapping.sh" "${fastq_files}" "${genome_index_files}" "${output_dir_mapping}"
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

    // Define input: each .bam file from the mapped_bam channel and the parameter defined as param.max_mismatch
    input:
    path bam_file
    val max_mismatch

    // Define output directories
    def filtered_dir = "${params.output_dir}/Filtered"
    def sorted_dir = "${params.output_dir}/Sorted"

    // Pass sorted .bam files
    output:
    path "*_sorted.bam", emit: sorted_bam

    // Run processing script
    script:
    """
    mkdir -p ${filtered_dir} ${sorted_dir}
    bash "${params.scripts_dir}/Post-map-process.sh" "${bam_file}" "${filtered_dir}" "${sorted_dir}" "${max_mismatch}"
    """
}

// Process 3: Peak calling using MACS2
process PeakCalling {
    tag "Peak-Calling Process"

    // Define input: each .bam file from the sorted_bam channel
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
    bash /home/DDGcarlos/Chipseq-analysis/Scripts/Peak-calling.sh \\
        "${metadata}" \\                 # Metadata file
        "${ext_size}" \\                 # Average fragment length (i.e. minimal peak size)
        "${sorted_dir}" \\               # Bam files used as input
        "${peaks_dir}" \\                # Output directory
    """
}


// Workflow
workflow {
    def fastq_files = Channel.fromPath("${params.fastq_dir}/*.fastq")
    def genome_index_files = Channel.fromPath("${params.genome_index_base}/*.ht2").collect()
    mapped_bam = Mapping(fastq_files, genome_index_files)
    sorted_bam = PostMapping(mapped_bam, Channel.value(params.max_mismatch))
    PeakCalling(file(params.metadata), params.ext_size, sorted_bam.collect())
}
