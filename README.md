# Histone-ChIP-seq-analysis

This workflow requires previously filtered .fastq files from ChIP-seq experiments. Fragment length is optimized for histone marks but may be changed for other proteins.

## Installation

To install the pipeline:

```bash
git clone https://github.com/ccarloscr
cf Histone-ChIP-seq-analysis
./chipseq_workflow.nf --help
```

This workflow depends on multiple dependencies installed in a conda environment named chipseq env (environment.yml). 

## Comments

The scripts do not include THREAD options as they were written for a SLURM-based cluster.




