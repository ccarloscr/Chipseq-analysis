# Histone-ChIP-seq-analysis

This workflow processes pre-filtered .fastq files from ChIP-seq experiments. The pipeline is optimized for histone mark analysis, but the fragment length parameters can be adjusted for other proteins.

The main Nextflow script (chipseq_workflow.nf) orchestrates the pipeline by calling the Bash scripts located in the Scripts/ directory. Each Bash script corresponds to a specific step in the workflow.


## Installation

To install the pipeline:

```bash
git clone https://github.com/ccarloscr
cf Histone-ChIP-seq-analysis
./chipseq_workflow.nf --help
```

This workflow depends on multiple tools and libraries, which are installed in the Conda environment named chipseq env (./environment.yml). Once the environment is created, it will be calles automatically by the ./chipseq_workflow.nf script.

To create the required conda environment:

```bash
conda env create -f environment.yml -n chipseq_env
```

## Comments

The scripts do not include THREAD options as they were written for a SLURM-based cluster.


Run the chipseq_workflow.nf script to activate the pipeline. It cou







