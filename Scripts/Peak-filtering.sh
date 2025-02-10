#!/bin/bash

## Comments
## This peak calling is optimized for reads with no strand information
## For strand-specific reads, remove the --nomodel and --extsize options of the macs2 callpeak

# Variable set up
INPUT_DIR="Histone_ChIPseq/Mapped/Sorted"
OUTPUT_DIR="Histone_ChIPseq/Peaks"
INPUT_NAME=""      # Name of input file (no antibody)
EXP_NAME=""        # Name of experimental file (antibody)
EXTSIZE="150"      # Average fragment length (i.e. minimal peak size)



mkdir -p $OUTPUT_DIR
