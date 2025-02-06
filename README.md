# Histone-ChIP-seq-analysis

This workflow processes pre-filtered .fastq files from ChIP-seq experiments. The pipeline is optimized for histone mark analysis, but the fragment length parameters can be adjusted for other proteins.

The main Nextflow script [`chipseq_workflow.nf`](chipseq_workflow.nf) orchestrates the pipeline by calling the Bash scripts located in the [`Scripts/`](Scripts/) directory. Each Bash script corresponds to a specific step in the workflow:


- [`Mapping.sh`](Scripts/Mapping.sh): Read mapping using HISAT2.
- [`Post-map-process.sh`](Scripts/Post-map-process.sh): Filtering, sorting and indexing of aligned files.
- [`Peak-calling.sh`](Scripts/Peak-calling.sh): Peak calling using MACS2.
- [`Liftover.sh`](Scripts/Liftover.sh): Liftover of peak coordinates from dm3 to dm6.
- [`Peak-filtering.sh`](Scripts/Peak-filtering.sh): Filtering of peaks located in non-canonical chromosomes.
- [`Peak-processing.sh`](Scripts/Peak-processing.sh): Annotation of peak features.
- [`Heatmaps.sh`](Scripts/Heatmaps.sh): Heatmap representation of annotated peaks.


## Installation

To install the pipeline:
```bash
git clone https://github.com/ccarloscr/Histone-ChIP-seq-analysis.git
cd Histone-ChIP-seq-analysis
./chipseq_workflow.nf --help
```

This workflow depends on multiple tools and libraries, which are installed in the Conda environment named chipseq env ([environment.yml](environment.yml)). Once the environment is created, it will be called automatically by the [`chipseq_workflow.nf`](chipseq_workflow.nf) script.

To create the required conda environment:
```bash
conda env create -f environment.yml -n chipseq_env
```

The [`Mapping.sh`](Scripts/Mapping.sh) script uses HISAT2 for the alignment of reads. HISAT2 requires the reference genome to work. For the _Drosophila melanogaster_ dm3 genome, run the following code in order to: (1) download the dm3 genome from UCSC, (2) activate the conda environment to get access to HISAT2, and (3) run HISAT2 to build the index of the downloaded genome.
```bash
mkdir -p ~/Histone-ChIP-seq-analysis/Genomes/dm3
cd ~/Histone-ChIP-seq-analysis/Genomes/dm3
wget http://hgdownload.soe.ucsc.edu/goldenPath/dm3/bigZips/dm3.fa.gz
gunzip dm3.fa.gz
conda activate chipseq_env
hisat2-build dm3.fa dm3_index
```


## Comments

SLURM-based THREAD options are included in the main Nextflow script.







