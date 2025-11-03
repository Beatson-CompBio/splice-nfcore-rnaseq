# SPLICE Bulk-RNAseq Modular Pipeline Usage Guide

## Overview

This custom RNA-seq pipeline now supports **modular execution**, allowing you to run individual stages or combinations without modifying the core code. This is perfect for:

- **Resuming interrupted workflows**
- **Testing individual stages**
- **Processing different data types**
- **Resource optimization**
- **Debugging specific steps**

## Directory Structure

Your pipeline expects this specific directory structure:

```
{job_id}/                           # UUID job directory (e.g., ae3a9e47-63cf-44ce-8405-10f67672ba2d)
├── input_data/
│   ├── containers/                 # Singularity cache (your pre-downloaded containers)
│   │   ├── depot.galaxyproject.org-singularity-fastqc-0.12.1--hdfd78af_0.img
│   │   ├── depot.galaxyproject.org-singularity-multiqc-1.30--pyhdfd78af_0.img
│   │   ├── depot.galaxyproject.org-singularity-samtools-1.17--h00cdaf9_0.img
│   │   └── ... (other containers)
│   ├── data/                       # Input data directory
│   │   ├── sample1_R1.fastq.gz
│   │   ├── sample1_R2.fastq.gz
│   │   ├── sample2_R1.fastq.gz
│   │   ├── sample2_R2.fastq.gz
│   │   ├── samplesheet.csv         # For full pipeline
│   │   ├── trimmed_samplesheet.csv # For quantification-only
│   │   ├── bam_samplesheet.csv     # For post-processing-only
│   │   ├── reference_genome.fasta
│   │   ├── reference_annotation.gtf
│   │   └── ... (other reference files)
│   └── nextflow/                   # Pipeline code
│       ├── main.nf
│       ├── nextflow.config
│       ├── conf/
│       ├── modules/
│       └── ... (full pipeline)
└── output_data/                    # Execution directory (run from here)
    ├── work/                       # Nextflow work directory
    ├── .nextflow/                  # Nextflow metadata
    └── results/                    # Output results
```

## Modular Execution Options

### **1. Preprocessing Only**
**What it runs**: FastQC → FastP → Strandedness inference → FastQC (post-trim)

**Use case**: Initial data QC and trimming

**Input required**: Raw FASTQ files + samplesheet

```bash
cd output_data/

nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,preprocessing_only \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  --fasta ../input_data/data/reference_genome.fasta \
  --gtf ../input_data/data/reference_annotation.gtf
```

**Output**:
- Trimmed FASTQ files
- FastQC reports (raw and trimmed)
- Strandedness inference results
- MultiQC preprocessing report

---

### **2. Quantification Only**
**What it runs**: STAR alignment → Salmon quantification (gene + transcript)

**Use case**: Have trimmed FASTQs, want counts

**Input required**: Trimmed FASTQ files + trimmed_samplesheet.csv

```bash
cd output_data/

nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,quantification_only \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  --fasta ../input_data/data/reference_genome.fasta \
  --gtf ../input_data/data/reference_annotation.gtf
```

**Output**:
- BAM files (genome and transcriptome)
- Gene and transcript count matrices
- STAR alignment logs
- Salmon quantification results

---

### **3. Post-processing Only**
**What it runs**: SAMtools → Picard MarkDuplicates → BEDtools → BigWig → MultiQC

**Use case**: Have BAM files, want final processed outputs

**Input required**: BAM files + bam_samplesheet.csv

```bash
cd output_data/

nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,postprocessing_only \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  --fasta ../input_data/data/reference_genome.fasta
```

**Output**:
- Processed BAM files (sorted, indexed, deduplicated)
- BigWig coverage files
- Comprehensive QC report

---

### **4. Preprocessing + Quantification**
**What it runs**: FastQC → FastP → STAR-Salmon → Gene/Transcript counts

**Use case**: Want counts but skip post-processing

```bash
cd output_data/

nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,preprocess_quantify \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  --fasta ../input_data/data/reference_genome.fasta \
  --gtf ../input_data/data/reference_annotation.gtf
```

---

### **5. Quantification + Post-processing**
**What it runs**: STAR-Salmon → SAMtools → Picard → BEDtools → BigWig

**Use case**: Have trimmed FASTQs, want final processed outputs

```bash
cd output_data/

nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,quantify_postprocess \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  --fasta ../input_data/data/reference_genome.fasta \
  --gtf ../input_data/data/reference_annotation.gtf
```

---

### **6. Full Pipeline**
**What it runs**: All stages (your original streamlined configuration)

**Use case**: Complete analysis from raw FASTQs to final outputs

```bash
cd output_data/

nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,full_pipeline \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  --fasta ../input_data/data/reference_genome.fasta \
  --gtf ../input_data/data/reference_annotation.gtf
```

## Sample Sheets for Different Stages

### **1. Standard Samplesheet (samplesheet.csv)**
For full pipeline and preprocessing:
```csv
sample,fastq_1,fastq_2,strandedness
sample1,../input_data/data/sample1_R1.fastq.gz,../input_data/data/sample1_R2.fastq.gz,auto
sample2,../input_data/data/sample2_R1.fastq.gz,../input_data/data/sample2_R2.fastq.gz,auto
```

### **2. Trimmed Samplesheet (trimmed_samplesheet.csv)**
For quantification-only (after preprocessing):
```csv
sample,fastq_1,fastq_2,strandedness
sample1,../output_data/preprocessing_results/sample1/sample1_1.trim.fastq.gz,../output_data/preprocessing_results/sample1/sample1_2.trim.fastq.gz,forward
sample2,../output_data/preprocessing_results/sample2/sample2_1.trim.fastq.gz,../output_data/preprocessing_results/sample2/sample2_2.trim.fastq.gz,forward
```

### **3. BAM Samplesheet (bam_samplesheet.csv)**
For post-processing-only (after quantification):
```csv
sample,bam,bai
sample1,../output_data/quantification_results/sample1/sample1.Aligned.out.bam,../output_data/quantification_results/sample1/sample1.Aligned.out.bam.bai
sample2,../output_data/quantification_results/sample2/sample2.Aligned.out.bam,../output_data/quantification_results/sample2/sample2.Aligned.out.bam.bai
```

## 🐳 Container Management

### **Singularity Cache Setup**
Your containers are pre-cached in `../input_data/containers/`. The pipeline will automatically use this cache:

```bash
# Example container files in cache:
../input_data/containers/
├── depot.galaxyproject.org-singularity-fastqc-0.12.1--hdfd78af_0.img
├── depot.galaxyproject.org-singularity-fastp-0.23.4--h5f740d0_0.img  
├── depot.galaxyproject.org-singularity-star-2.7.10a--h9ee0642_0.img
├── depot.galaxyproject.org-singularity-salmon-1.10.1--h7e5ed60_0.img
├── depot.galaxyproject.org-singularity-samtools-1.17--h00cdaf9_0.img
├── depot.galaxyproject.org-singularity-picard-3.0.0--hdfd78af_0.img
└── ...
```

### **Pre-downloading Containers**
```bash
# If you need to pre-download containers:
singularity pull --dir ../input_data/containers/ docker://biocontainers/fastqc:0.12.1--hdfd78af_0
singularity pull --dir ../input_data/containers/ docker://biocontainers/fastp:0.23.4--h5f740d0_0
singularity pull --dir ../input_data/containers/ docker://biocontainers/mulled-v2-1fa26d1ce03c295fe2fdcf85831a92fbcbd7e8c2:59cdd445419f14abac76b31dd0d71217994cbcc9-0
# ... etc for all containers
```

## Output Organization

### **With job_id and short_job_id**
```
output_data/
└── results/
    └── ae3a9e47-63cf-44ce-8405-10f67672ba2d/    # job_id directory
        ├── fastqc/
        │   ├── a123_sample1_fastqc.html           # short_job_id prefix
        │   └── a123_sample2_fastqc.html
        ├── star_salmon/
        │   ├── a123_salmon.merged.gene_counts.tsv
        │   └── a123_salmon.merged.transcript_counts.tsv
        └── multiqc/
            └── a123_multiqc_report.html
```

### **Resource Usage by Profile**

| Profile | STAR Memory | STAR CPUs | Salmon Memory | Salmon CPUs | Runtime |
|---------|------------|-----------|---------------|-------------|---------|
| preprocessing_only | - | - | - | - | 1-4h |
| quantification_only | 64GB | 16 | 16GB | 8 | 4-12h |
| postprocessing_only | - | - | - | - | 2-6h |
| full_pipeline | 64GB | 16 | 16GB | 8 | 6-24h |

## Advanced Usage

### **Custom Parameters**
```bash
# Override default paths
nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,quantification_only \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  --data_path /custom/path/to/data \
  --container_cache_path /custom/path/to/containers

# Override resource requirements
nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,full_pipeline \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --max_memory 128.GB \
  --max_cpus 24
```

### **Resume Functionality**
```bash
# Resume failed runs
nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,full_pipeline \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  -resume
```

### **Testing Stages**
```bash
# Test with minimal resources
nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc,preprocessing_only \
  --job_id test_run \
  --short_job_id test \
  --max_cpus 4 \
  --max_memory 16.GB
```

## Benefits of Modular Approach

1. **Resource Efficiency** - Only use resources for needed stages
2. **Debugging** - Isolate and test problematic stages
3. **Flexibility** - Different input sources for each stage
4. **Resumability** - Continue from any point in the workflow
5. **Cost Optimization** - Run intensive stages only when needed
6. **Development** - Test individual components during development

