#!/bin/bash
# NGS Analysis Pipeline

# Define variables for ease of customization
SAMPLES=("ACBarrie" "Alsen" "Baxter" "Chara" "Drysdale")  # Sample names
RAW_DIR="raw_reads"     # Directory containing raw reads
TRIMMED_DIR="Trimmed_reads"
ALIGNMENT_DIR="Alignment"
RESULT_DIR="Result"
REFERENCE="Reference/reference.fasta"  # Path to the reference genome
QC_DIR="QC_report"

# Create output directories if they don't exist
mkdir -p $QC_DIR $TRIMMED_DIR $ALIGNMENT_DIR $RESULT_DIR

# Step 1: Quality check using FastQC
for SAMPLE in "${SAMPLES[@]}"; do
    echo "Running FastQC on $SAMPLE..."
    fastqc ${RAW_DIR}/${SAMPLE}_R1.fastq.gz ${RAW_DIR}/${SAMPLE}_R2.fastq.gz -o $QC_DIR

    if [ $? -ne 0 ]; then
        echo "Error in FastQC for $SAMPLE. Exiting."
        exit 1
    fi
done

# Step 2: Repair reads using bbtools repair.sh for each sample
for SAMPLE in "${SAMPLES[@]}"; do
    echo "Repairing reads for $SAMPLE..."
    repair.sh in1=${RAW_DIR}/${SAMPLE}_R1.fastq.gz \
              in2=${RAW_DIR}/${SAMPLE}_R2.fastq.gz \
              out1=${TRIMMED_DIR}/${SAMPLE}_R1_repaired.fastq.gz \
              out2=${TRIMMED_DIR}/${SAMPLE}_R2_repaired.fastq.gz \
              outs=${TRIMMED_DIR}/${SAMPLE}_singletons.fastq.gz
              overwrite=true
    if [ $? -ne 0 ]; then
        echo "Error in repairing reads for $SAMPLE. Exiting."
        exit 1
    fi
done

# Step 3: Trim reads using fastp
for SAMPLE in "${SAMPLES[@]}"; do
    echo "Trimming reads for $SAMPLE..."
    fastp -i ${TRIMMED_DIR}/${SAMPLE}_R1_repaired.fastq.gz -I ${TRIMMED_DIR}/${SAMPLE}_R2_repaired.fastq.gz \
          -o ${TRIMMED_DIR}/${SAMPLE}_R1_trimmed.fastq.gz \
          -O ${TRIMMED_DIR}/${SAMPLE}_R2_trimmed.fastq.gz

    if [ $? -ne 0 ]; then
        echo "Error in trimming for $SAMPLE. Exiting."
        exit 1
    fi
done

# Step 4: Index the reference genome for BWA
if [ ! -f "${REFERENCE}.bwt" ]; then
    echo "Indexing the reference genome..."
    bwa index $REFERENCE
    if [ $? -ne 0 ]; then
        echo "Error in indexing reference genome. Exiting."
        exit 1
    fi
fi

# Step 5: Align reads using BWA-MEM for each sample
for SAMPLE_ID in "${SAMPLES[@]}"; do
    echo "Aligning reads for $SAMPLE_ID..."
    bwa mem $REFERENCE ${TRIMMED_DIR}/${SAMPLE_ID}_R1_trimmed.fastq.gz \
            ${TRIMMED_DIR}/${SAMPLE_ID}_R2_trimmed.fastq.gz > ${ALIGNMENT_DIR}/${SAMPLE_ID}.sam
    if [ $? -ne 0 ]; then
        echo "Error in alignment for $SAMPLE_ID. Exiting."
        exit 1
    fi
done

# Step 6: Convert SAM to BAM for each sample
for SAMPLE_ID in "${SAMPLES[@]}"; do
    echo "Converting SAM to BAM for $SAMPLE_ID..."
    samtools view -bS ${ALIGNMENT_DIR}/${SAMPLE_ID}.sam > ${ALIGNMENT_DIR}/${SAMPLE_ID}.bam
    if [ $? -ne 0 ]; then
        echo "Error in SAM to BAM conversion for $SAMPLE_ID. Exiting."
        exit 1
    fi
done

# Step 7: Sort BAM files for each sample
for SAMPLE_ID in "${SAMPLES[@]}"; do
    echo "Sorting BAM file for $SAMPLE_ID..."
    samtools sort ${ALIGNMENT_DIR}/${SAMPLE_ID}.bam -o ${ALIGNMENT_DIR}/${SAMPLE_ID}_sorted.bam
    if [ $? -ne 0 ]; then
        echo "Error in sorting BAM for $SAMPLE_ID. Exiting."
        exit 1
    fi
done

# Step 8: Index sorted BAM files for each sample
for SAMPLE_ID in "${SAMPLES[@]}"; do
    echo "Indexing BAM file for $SAMPLE_ID..."
    samtools index ${ALIGNMENT_DIR}/${SAMPLE_ID}_sorted.bam
    if [ $? -ne 0 ]; then
        echo "Error in indexing BAM for $SAMPLE_ID. Exiting."
        exit 1
    fi
done

# Step 9: Call variants using bcftools for each sample
for SAMPLE_ID in "${SAMPLES[@]}"; do
    echo "Calling variants for $SAMPLE_ID..."
    bcftools mpileup -f $REFERENCE ${ALIGNMENT_DIR}/${SAMPLE_ID}_sorted.bam | \
    bcftools call --ploidy 1 -mv -Oz -o ${RESULT_DIR}/${SAMPLE_ID}.vcf.gz
    if [ $? -ne 0 ]; then
        echo "Error in variant calling for $SAMPLE_ID. Exiting."
        exit 1
    fi
done

# Step 10: Filter variants for each sample
for SAMPLE_ID in "${SAMPLES[@]}"; do
    echo "Filtering variants for $SAMPLE_ID..."
 # Decompress the VCF if it's gzipped
    gunzip -c ${RESULT_DIR}/${SAMPLE_ID}.vcf.gz > ${RESULT_DIR}/${SAMPLE_ID}.vcf

    vcfutils.pl varFilter -d 10 -Q 20 ${RESULT_DIR}/${SAMPLE_ID}.vcf > ${RESULT_DIR}/${SAMPLE_ID}_filtered.vcf
    if [ $? -ne 0 ]; then
        echo "Error in filtering variants for $SAMPLE_ID. Exiting."
        exit 1
    fi
done

echo "NGS pipeline complete for all samples."
