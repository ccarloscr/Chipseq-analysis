#!/usr/bin/env Rscript

## Comments
## This R script transforms dm3 peaks into dm6, filters out non-canonical chromosomes, and annotates its genomic features.

## Define variables
around_tss <- 500    # Sets the bp range around the TSS
canonical_chromosomes <- c("chr2L", "chr2R", "chr3L", "chr3R", "chr4", "chrX", "chrY")


## Install and load the required packages

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

cran_packages <- c("dplyr", "purrr", "R.utils")
bioc_packages <- c("ChIPseeker", "TxDb.Dmelanogaster.UCSC.dm3.ensGene", "TxDb.Dmelanogaster.UCSC.dm6.ensGene", "org.Dm.eg.db", "clusterProfiler", "rtracklayer")

install_cran <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)}
}

install_bioc <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    BiocManager::install(pkg, dependencies = TRUE)}
}

lapply(cran_packages, install_cran)
lapply(bioc_packages, install_bioc)

library(dplyr)
library(purrr)
library(R.utils)
library(ChIPseeker)
library(TxDb.Dmelanogaster.UCSC.dm3.ensGene)
library(TxDb.Dmelanogaster.UCSC.dm6.ensGene)
library(org.Dm.eg.db)
library(clusterProfiler)
library(rtracklayer)



## Prepare the chain file for the LiftOver process from dm3 to dm6

# Define the URL and local file path
chain_url <- "https://hgdownload.soe.ucsc.edu/gbdb/dm3/liftOver/dm3ToDm6.over.chain.gz"
chain_file <- "dm3ToDm6.over.chain.gz"

# Download the file
if (!file.exists(chain_file)) {
  download.file(chain_url, destfile = chain_file, mode = "wb")
}

# Decompress the file
gunzip(chain_file, remove = FALSE)
chain_file_unzipped <- sub(".gz", "", chain_file)

# Import the decompressed chain file
if (file.exists(chain_file_unzipped)) {
  chain <- import.chain(chain_file_unzipped)
}
else {stop("Unzipped file does not exist: ", chain_file_unzipped)
}



## Create a list of GRanges from the .narrowPeak files

# Set the input folder location
input_folder <- "Chipseq-analysis/Peaks"

# List all .narrowPeak files
input_files <- list.files(input_folder, pattern = "\\.narrowPeak$", full.names = TRUE)

# Create list of GRange objects (one for each .narrowPeak file)
peaks_list <- input_files %>%
  set_names(basename(input_files) %>% gsub("\\.narrowPeak$", "_peaks", .)) %>%
  map(~ readPeakFile(.))



## LiftOver from dm3 to dm6

peaks_list_dm6 <- peaks_list %>%
  map(~ liftOver(., chain)) %>%    # Generates GRangesList for each GRanges
  map(~ unlist(.))                 # Converts GRangesList into GRanges, deleting non-converted regions
  map(~.[width(.) > 0])            # Removes empty regions


## Annotation of dm6 peaks

# Iterate each GRange object
annotate_peaks <- lapply(peaks_list_dm6, function(peaks) {

  # Filter out peaks in non-canonical chromosomes
  filtered_peaks <- peaks[as.character(seqnames(peaks)) %in% canonical_chromosomes]

  # Annotate filtered peaks into dm6
  annotatePeak(filtered_peaks ,
                tssRegion = c(-around_tss, around_tss),
                TxDb = TxDb.Dmelanogaster.UCSC.dm6.ensGene,
                annoDb = "org.Dm.eg.db")
})



## Save peak annotation data

output_folder <- "Chipseq-analysis/Annotated-peaks-dm6"
dir.create(output_folder, showWarnings = FALSE)

invisible(lapply(seq_along(annotate_peaks), function(i) {
  output_file <- file.path(output_folder, paste0(names(annotate_peaks)[i], "_annot-dm6.txt"))
  write.table(as.data.frame(annotate_peaks[[i]]), file = output_file, sep = "\t", quote = FALSE, row.names = FALSE)
}))





