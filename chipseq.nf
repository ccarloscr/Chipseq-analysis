#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Default parameters
params.home_dir = "/home/DDGcarlos/Chipseq-analysis"
params.scripts_dir = "${params.home_dir}/Scripts"
params.fastq_dir = "${params.home_dir}/Fastq_files"
params.genome_index = "${params.home_dir}/Genomes/dm3"
params.genome_index_base = "${params.home_dir}/Genomes/dm3/dm3_index"
params.metadata = "${params.home_dir}/metadata.csv"
params.output_dir = "${params.home_dir}/Results"
params.max_mismatch = 4    // Maximum mismatch base pairs allowed per alignment
params.ext_size = 150    // Average fragment length; i.e. maximum peak size


// Process 1: mapping using HISAT2
process Mapping {
    tag "Mapping Process"
    publishDir "${params.output_dir}/Mapped",
        mode: 'copy',
        pattern: '*.bam',
        overwrite: true

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
    bash "${params.scripts_dir}/Mapping.sh" "${fastq_files}" "${genome_index_files}" "."
    """
}

// Process 2: Filtering, sorting and indexing of .bam files
process PostMapping {
    tag "Post-Mapping Process"
    publishDir "${params.output_dir}/Sorted",
        mode: 'copy',
        pattern: '*_sorted.bam',
        overwrite: true

    // Define input: each .bam file from the mapped_bam channel and the parameter defined as param.max_mismatch
    input:
    path bam_file
    val max_mismatch

    // Pass sorted .bam files
    output:
    path "*_sorted.bam", emit: sorted_bam

    // Run processing script
    script:
    """
    bash "${params.scripts_dir}/Post-map-process.sh" "${bam_file}" "." "${max_mismatch}"
    """
}

// Process 3: Collect al _sorted.bam files into a signle directory
process CollectBams {
    tag "Collect BAMs"
    publishDir "${params.output_dir}/Sorted",
        mode: 'copy',
        overwrite: true

    input:
    path bam_files

    output:
    path "sorted_bams/", emit: sorted_bam_dir

    script:
    """
    mkdir -p sorted_bams
    cp -t sorted_bams/ ${bam_files}
    """
}

// Process 4: Peak calling using MACS2
process PeakCalling {
    tag "Peak-Calling Process"
    publishDir "${params.output_dir}/Peaks-called",
        mode: 'copy',
        pattern: '*.narrowPeak',
        overwrite: true

    // Define input: each .bam file from the sorted_bam channel
    input:
    path metadata
    val ext_size
    path sorted_bam_dir

    // Define output directory and capture output .narrowPeak files into narrow_peaks channel
    output:
    path "*.narrowPeak", emit: narrow_peaks

    // Run peak calling script
    script:
    """
    echo "Checking contents of sorted_bams:"
    ls -lh sorted_bams
    bash "${params.scripts_dir}/Peak-calling.sh" "${metadata}" "${ext_size}" "${sorted_bam_dir}" "."
    """
}


// Process 5: LiftOver and annotation of peaks
process LiftOver_Annotation {
    tag "LiftOVer and Annot Process"
    publishDir "${params.output_dir}/Annotated-peaks-dm6",
        mode: 'copy',
        pattern: '*_annot-dm6.txt',
        overwrite: true

    input:
    path narrow_peak_files

    output:
    path "*_annot-dm6.txt", emit: annotated_peaks

    script:
    """
    Rscript "${params.scripts_dir}/Peak-annotation.R" "$PWD"
    """
}



// Workflow
workflow {
    def fastq_files = Channel.fromPath("${params.fastq_dir}/*.fastq")
    def genome_index_files = Channel.fromPath("${params.genome_index}/*.ht2").collect()
    mapped_bam = Mapping(fastq_files, genome_index_files)
    sorted_bam = PostMapping(mapped_bam, Channel.value(params.max_mismatch))
    collected_bams = CollectBams(sorted_bam.collect())
    narrow_peaks = PeakCalling(file(params.metadata), params.ext_size, collected_bams)
    LiftOver_Annotation(narrow_peaks)
}
