<h1 align="center">🧬Metagenomic-analysis-for-Nanopore-reads - A bioinformatic analysis of Nanopore sequencing data from wastewater</h1>
<p align="center"> This project analyzes wastewater diversity through CZ.ID NANOPORE pipeline and workflow Wf-metagenomics from EPI2ME and visualized by the report from the output of EPI2ME and using R.
</p>
---

## Final File Structure
```text
project
├── czid/
├── database/
├── epi2me
│   └── abundance
│   │   ├── abundance_table_pluspf.tsv
│   │   ├── abundance_table_standard.tsv
│   │   └── abundance_table_viral.tsv
│   └── reports
│   │   ├── viral.html
│   │   ├── standar.html
│   │   └── pluspf.html
│   └── unclassified
│       ├── unclassified_viral/
│       ├── unclassified_standard/
│       └── inclassified_pluspf/
├── exclude_host
│   └── GCF_000001405.40_GRCh38.p14_genomic.fna
├── output/
├── samples
│   └── samples/
├── sample_sheet
│   └── sample_sheet.csv
├── store_dir/
├── taxonomy.py
└── taxonomy.excel
```
Each time the workflow is executed with a diferent database, it is necessary to transfer the following documents: `wf-metagenomics-report.html`, `abundance_table_species.tsv` and the files from the folder `unclassified`, so that the files are not substitute by the next reports.  

```sh bash
mv output/wf-metagenomics-report.html epi2me/reports/_viral.html
mv output/abundance_table_species.tsv epi2me/abundance_table_viral.tsv
mv output/unclassified/*.fq.gz epi2me/unclassified/unclassified_viral
```


