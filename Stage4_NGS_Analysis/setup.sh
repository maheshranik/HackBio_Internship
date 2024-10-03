#!/bin/bash
# Install tools necessary for the NGS pipeline

# Add channels for Conda
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

# Install NGS tools
conda install -c bioconda bwa
conda install -c bioconda samtools
conda install -c bioconda bcftools
conda install -c bioconda fastqc
conda install -c bioconda fastp
conda install -c bioconda bbtools

echo "All tools installed."
