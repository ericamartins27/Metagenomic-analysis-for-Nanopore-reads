<h1 align="center">🧬Metagenomics Analysis of Oxford Nanopore Wastewater Sequencing Data</h1>
<p align="center"> This repository contains the bioinformatic workflows, scripts and analyses developed during a internship in Institute of Higiene and Tropical Medicine of NOVA University. The project aims to focuses on the metagenomic analysis of Oxford Nanopore sequencing data obtained from wastewater samples for microbial surveillance. Two bioinformatics platforms (EPI2ME wf-metagenomics and CZ.ID) were evaluated and compared for taxonomic classification of bacteria, viruses, bacteriophages and potencial human pathogens. Data visualization and statiscal analyses were performed using R.</p>

## 👤 Author 
  - Érica Martins             
## 👥 Advisors
  - Francisco Pina Martins
  - Sofia Gonçalves Seabra
  - Ricardo Parreira
---


## ⚙️ Requirements
  - Linux-based system
  - `CZ.ID`, `EPI2ME wf-metagenomics`
  - `Docker` (v29.1.3), `Nextflow` (v23.10.1), `Java` (`default-jre`, v17.0.19 ), Python (v.3.12.3) 
  - `R` (v2026.06.0)

## 🗃️ Databases
### Kraken2 databases
The workflow was evaluated using three Kraken2 databases: 
  - **Standard** - Refseq archaea, bacteria, viral, plasmid, human, UniVec_Core (79.6 GB)
  - **PlusPF** - Standard plus Refseq protozoa, fungi & plant (171.8 GB)
  - **Viral** - Refseq viral (0.5 GB)

The databases were downloaded from the Kraken2 index repository:
[Download here](https://benlangmead.github.io/aws-indexes/k2#older-minikraken-indexes)

### Host genome
The human reference genome for host read removal was *Homo sapiens GRCh38.P14*, downloaded from the **NCBI Assembly**.

[NCBI Assembly - GRCh38.P14](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001405.40/)


## 🗂️ File Structure
```text
/dados/project
├── czid/
├── database/
├── epi2me
│   └── abundance/
│   └── reports/
│   └── unclassified/
├── exclude_host/
├── output/
├── samples
│   └── samples/
├── sample_sheet/
├── store_dir/
├── taxonomy.py
└── taxonomy.xlsx
```

## ▶️ Usage Steps
1. Download the `csv` results from CZ.ID pipeline and store them in the `czid` folder.
2. Download the host genome and store it in the `exclude_host` folder.
3. Download the three databases to the `database` folder.
4. Run the EPI2ME *wf-metagenomics* with Nextflow:
```bash
  nextflow run epi2me-labs/wf-metagenomics \
    --fastq '/dados/project/samples/samples' \
    --min_len 200 \
    --exclude_host '/dados/project/exclude_host/GCF_000001405.40_GRCh38.p14_genomic.fna' \
    --classifier kraken2 \
    --sample_sheet '/dados/project/sample_sheet/samples_sheet.csv' \
    --database '/dados/project/database/k2_viral_20260226.tar.gz' \
    --taxonomic_rank S \
    --amr
    --amr_db resfinder   # and card
    --output_unclassified
```
5. Each time the workflow is executed with a diferent database, it is necessary to transfer the following documents from the output: `wf-metagenomics-report.html`, `abundance_table_species.tsv` and `*.fq.gz` from the folder `unclassified`, so that the files are not substitute by the next reports.  
```sh bash
mv output/wf-metagenomics-report.html epi2me/reports/viral.html
mv output/abundance_table_species.tsv epi2me/abundance/abundance_table_viral.tsv
mv output/unclassified/*.fq.gz epi2me/unclassified/unclassified_viral
```
6. Run the taxonomy.py script with Python:
```sh bash
python taxonomy.py
```
7. Run the R analysis that performs statistical analyses (alpha diversity, composition, indicator species and genus).

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
