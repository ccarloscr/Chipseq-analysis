#!/usr/bin/env Rscript

## Comments
## This script annotates previously called peaks

## Options
## The following variables are standard and can be changed

around_tss <- 500    # Sets the bp range around the TSS



## Install and load the required packages

packages <- c("dplyr")
bioc_packages <- c("ChIPseeker", "TxDb.Dmelanogaster.UCSC.dm3.ensGene", "TxDb.Dmelanogaster.UCSC.dm6.ensGene", "org.Dm.eg.db", "clusterProfiler", "liftOver")

install?????????




install_bioc_package <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    BiocManager::install(pkg, dependencies = TRUE)}}

for (pkg in bioc_packages) {
  install_bioc_package(pkg)}



library(dplyr)
library(ChIPseeker)
library(TxDb.Dmelanogaster.UCSC.dm3.ensGene)
library(TxDb.Dmelanogaster.UCSC.dm6.ensGene)
library(org.Dm.eg.db)
library(clusterProfiler)
library(liftOver)



## Annotate all peaks

input_folder <- "Chipseq-analysis/Peaks"

# List all .narrowPeak files
input_files <- list.files(input_folder, pattern = "\\.narrowPeak$", full.names = TRUE)

# Create list of variables (one for each .narrowPeak file)
peaks_list <- input_files %>%
  set_names(basename(input_files) %>% gsub("\\.narrowPeak$", "_peaks", .)) %>%
  map(~ read.table(.))

# Iterate each narrowPeak file and annotate it using dm3
annotate_peaks <- lapply(peaks_list, function(peaks) {
  annotatePeak( peaks,
                tssRegion = c(-around_tss, around_tss),
                TxDb = TxDb.Dmelanogaster.UCSC.dm3.ensGene,
                annoDb = "org.Dm.eg.db")
  })


## Filter out peaks in non-canonical chromosomes





