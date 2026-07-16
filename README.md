<h1 align="center">🧬Metagenomic-analysis-for-Nanopore-reads - A bioinformatic analysis of Nanopore sequencing data from wastewater</h1>
<p align="center"> This project analyzes wastewater diversity through CZ.ID NANOPORE pipeline and workflow Wf-metagenomics from EPI2ME and visualized by the report from the output of EPI2ME and using R.
</p>
---

## Final File Structure
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
Each time the workflow is executed with a diferent database, it is necessary to transfer the `report`, `abundance` and `unclassified`.  
```sh
bash mv output/ epi2me/reports/_viral.tsv
bash mv output/abundance_table_species.tsv epi2me/abundance_table_viral.tsv
bash mv output/unclassified/*.fq.gz epi2me/unclassified/unclassified_viral
```


