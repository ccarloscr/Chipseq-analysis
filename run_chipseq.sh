#!/bin/bash
#SBATCH --job-name=chipseq
#SBATCH --partition=irbio01
#SBATCH --cpus-per-task=12
#SBATCH --time=10:00:00
#SBATCH --output=chipseq_%j.out
#SBATCH --error=chipseq_%j.err

# Load the nextflow module
module load nextflow

# Run the nextflow script
nextflow run chipseq.nf
