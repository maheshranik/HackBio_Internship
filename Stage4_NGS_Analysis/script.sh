#!/bin/bash
# Pipeline for NGS analysis

# Step 1: Quality check using FastQC
fastqc raw_reads/ERR8774458_1.fastq.gz raw_reads/ERR8774458_2.fastq.gz -o QC_report/

# Step 2: Trim reads using fastp (adjust parameters as necessary)
fastp -i raw_reads/ERR8774458_1.fastq.gz -I raw_reads/ERR8774458_2.fastq.gz -o Trimmed_reads/ERR8774458_1_trimmed.fastq.gz -O Trimmed_reads/ERR8774458_2_trimmed.fastq.gz

# Step 3: Repair reads using bbtools repair.sh
repair.sh in1=Trimmed_reads/ERR8774458_1_trimmed.fastq.gz in2=Trimmed_reads/ERR8774458_2_trimmed.fastq.gz out1=Trimmed_reads/ERR8774458_1_repaired.fastq.gz out2=Trimmed_reads/ERR8774458_2_repaired.fastq.gz outs=Trimmed_reads/singletons.fastq.gz

# Step 4: Align reads using BWA-MEM
bwa mem Reference/Reference.fasta Trimmed_reads/ERR8774458_1_repaired.fastq.gz Trimmed_reads/ERR8774458_2_repaired.fastq.gz > Alignment/ERR8774458.sam

# Step 5: Convert SAM to BAM
samtools view -bS Alignment/ERR8774458.sam > Alignment/ERR8774458.bam

# Step 6: Sort BAM file
samtools sort Alignment/ERR8774458.bam -o Alignment/ERR8774458_sorted.bam

# Step 7: Index sorted BAM file
samtools index Alignment/ERR8774458_sorted.bam

# Step 8: Call variants using bcftools
bcftools mpileup -f Reference/Reference.fasta Alignment/ERR8774458_sorted.bam | bcftools call --ploidy 1 -mv -Oz -o Result/ERR8774458.vcf.gz

# Step 9: Filter variants
bcftools filter -s LowQual -e '%QUAL<20 || DP<10' Result/ERR8774458.vcf.gz > Result/ERR8774458_filtered.vcf.gz

echo "Pipeline complete."
