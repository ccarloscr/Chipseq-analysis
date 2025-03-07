#!/usr/bin/env Rscript

## Comments
## This R script is designed specifically for Drosophila melanogaster genomes dm3 or dm6
## First, if the reference genome is dm3, performs a liftOver to dm6
## Then, non-canonical chromosomes are filtered and peaks are annotated to genomic features
### Other genomes could be used if TxDb genome files are changed (as well as the canonical chromosomes passed)



## Load the required packages

cran_packages <- c("dplyr", "purrr", "R.utils")
bioc_packages <- c("ChIPseeker", "TxDb.Dmelanogaster.UCSC.dm3.ensGene", "TxDb.Dmelanogaster.UCSC.dm6.ensGene", "org.Dm.eg.db", "clusterProfiler", "rtracklayer")

load_library <- function(pkg) {
  library(pkg, character.only = TRUE)
}

lapply(cran_packages, load_library)
lapply(bioc_packages, load_library)



## Define variables

args <- commandArgs(trailingOnly = TRUE)
input_folder <- args[1]
around_tss <- as.numeric(args[2])
canonical_chromosomes <- unlist(strsplit(args[3], ","))
dm_genome <- args[4]
output_folder <- args[5]

# Check that input folder exists
if (!dir.exists(input_folder)) {
  stop("Input directory does not exist: ", input_folder)
}



## Create a list of GRanges from the .narrowPeak files

# List all .narrowPeak files
input_files <- list.files(input_folder, pattern = "\\.narrowPeak$", full.names = TRUE)

# Check the presence of .narrowPeak files
if (length(input_files) == 0) {
  stop("No .narrowPeak files found in directory: ", input_folder)
}

# Create list of GRange objects (one for each .narrowPeak file)
peaks_list <- input_files %>%
  set_names(basename(input_files) %>% gsub("\\.narrowPeak$", "_peaks", .)) %>%
  map(~ readPeakFile(.))



## Prepare for the LiftOver if the mapped genome is dm3

if (as.character(dm_genome) == "dm3") {

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

}
  


## LiftOver from dm3 to dm6 if the mapped genome is dm3

if (as.character(dm_genome) == "dm3") {
  peaks_list_dm6 <- peaks_list %>%
    map(~ liftOver(., chain) %>%      # Generates GRangesList for each GRanges
      unlist() %>%                    # Converts GRangesList into GRanges, deleting non-converted regions
      .[width(.) > 0]                 # Removes empty regions
    )
}
else {peaks_list_dm6 <- peaks_list
}



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
}
)



## Save peak annotation data

dir.create(output_folder, showWarnings = FALSE)

invisible(lapply(seq_along(annotate_peaks), function(i) {
  output_file <- file.path(output_folder, paste0(names(annotate_peaks)[i], "_annot-dm6.txt"))
  write.table(as.data.frame(annotate_peaks[[i]]), file = output_file, sep = "\t", quote = FALSE, row.names = FALSE)
}
)
)



