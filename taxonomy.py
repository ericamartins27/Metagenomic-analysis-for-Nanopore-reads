
import os
from pathlib import Path
import pandas as pd


### Configuração ####
EPI2ME_DIR = "epi2me"
CZID_DIR = "czid"
OUTPUT_FILE = "taxonomy.xlsx"


# Função para separar a taxonomia
def split_taxonomy(tax):
    # splits the taxonomy string ento different taxonomic
    taxa = str(tax).split(";")
    # Ensures that there are always 8 levels, filling the missing ones
    while len(tax) < 8:
        taxa.append("")
    # Returns eachs taxonomic level
    return pd.Series({
        "Kingdom": taxa[0],
        "Taxon_2": taxa[1],
        "Phylum": taxa[2],
        "Class": taxa[3],
        "Order": taxa[4],
        "Family": taxa[5],
        "Genus": taxa[6],
        "Species": taxa[7]
    })


# Processar EPI2ME
def process_epi2me():
    all_data = []
    # Iterates through all TSV files in the EPI2ME folder
    for file in os.listdir(EPI2ME_DIR):
        if not file.endswith(".tsv"):
            continue
        filepath = os.path.join(EPI2ME_DIR, file)
        print(f"A processar {file}")
        filename = file.lower()
        # Identifies the database used
        if "plus" in filename:
            database = "PlusPF"
        elif "standard" in filename:
            database = "Standard"
        elif "viral" in filename:
            database = "Viral"
        else:
            database = "Unknown"
        df = pd.read_csv(filepath, sep="\t")
        if "total" in df.columns:
            df = df.drop(columns=["total"])
        # Converts the table from wide format (one column per samples) to long format (one row per taxon)
        df = df.melt(
            id_vars="tax",
            var_name="Sample",
            value_name="Abundance"
        )
        df["Abundance"] = pd.to_numeric(
            df["Abundance"],
            errors="coerce"
        )
        df = df[df["Abundance"] > 0]
        df["Abundance"] = df["Abundance"].astype(int)
        # Separates the taxonomy into independent columns
        taxonomy = df["tax"].apply(split_taxonomy)
        df = pd.concat([df, taxonomy], axis=1)
        # Adds information about the origin of the results
        df["Program"] = "EPI2ME"
        df["Database"] = database
        # Columns in the desired order
        df = df[[
            "Sample",
            "Program",
            "Database",
            "Kingdom",
            "Taxon_2",
            "Phylum",
            "Class",
            "Order",
            "Family",
            "Genus",
            "Species",
            "Abundance"
        ]]
        all_data.append(df)
    return pd.concat(all_data, ignore_index=True)


# Processar CZ.ID
def process_czid():
    all_data = []
    # Iterates through all CSV files in the CZ.ID folder
    for file in os.listdir(CZID_DIR):
        if not file.endswith(".csv"):
            continue
        filepath = os.path.join(CZID_DIR, file)
        print(f"A processar {file}")
        sample = Path(file).stem
        df = pd.read_csv(filepath)
        # Selects identificatiob at the species level
        df = df[df["tax_level"] == 1].copy()
        df = df.reset_index(drop=True)
        # Creates the final DataFrame with a format compatible, with the one used for EPI2ME results
        out = pd.DataFrame({
            "Sample": [sample] * len(df),
            "Program": ["CZ.ID"] * len(df),
            "Database": ["NA"] * len(df)
            })
        # Standardizes the names of the kingdms
        out["Kingdom"] = (
            df["category"]
            .replace({
                "bacteria": "Bacteria",
                "viruses": "Viruses",
                "eukaryota": "Eukaryota",
                "archaea": "Archaea"
            })
            .values)
        out["Taxon_2"] = "NA"
        out["Phylum"] = "NA"
        out["Class"] = "NA"
        out["Order"] = "NA"
        out["Family"] = "NA"
        out["Genus"] = df["name"].str.split().str[0].values
        out["Species"] = df["name"].values
        out["Abundance"] = "NA"
        out["nt_count"] = df["nt_count"].values
        out["known_pathogen"] = (
            df["known_pathogen"]
            .map({1: "Yes", 0: "No"})
            .values)
        # Adds columns that only exist on CZ.ID
        if "is_phage" in df.columns:
            out["is_phage"] = (
                df["is_phage"]
                .astype(str)
                .str.lower()
                .map({"true": "Yes", "false": "No"})
                .values)
        if "nt_percent_identity" in df.columns:
            out["nt_percent_identity"] = df["nt_percent_identity"]
        if "nt_alignment_length" in df.columns:
            out["nt_alignment_length"] = df["nt_alignment_length"]
        all_data.append(out)
        print(out.head())
        print(len(out))
    return pd.concat(all_data, ignore_index=True)


# Exportar
def export_excel(epi2me, czid):
    # Colunas que existem no CZ.ID mas não na EPI2ME
    epi2me["nt_count"] = ""
    epi2me["known_pathogen"] = ""
    epi2me["is_phage"] = ""
    epi2me["nt_percent_identity"] = ""
    epi2me["nt_alignment_length"] = ""
    # Columns present in EPI2ME but not in CZ.ID
    for col in epi2me.columns:
        if col not in czid.columns:
            czid[col] = ""
    # Colmns present in CZ.ID but not in EPI2ME
    for col in czid.columns:
        if col not in epi2me.columns:
            epi2me[col] = ""
    # Same column order
    czid = czid[epi2me.columns]
    # Combine the two DataFrames
    final = pd.concat([epi2me, czid], ignore_index=True)
    final = final.fillna("NA")
    final = final.replace("", "NA")
    final = final.reset_index(drop=True)
    # Export one single sheet
    with pd.ExcelWriter(OUTPUT_FILE, engine="openpyxl") as writer:
        final.to_excel(writer,
                       sheet_name="Resultados",
                       index=False)
    print(f"\nTotal de linhas exportadas: {len(final)}")

# Main
def main():
    print("PROCESSAR EPI2ME")
    epi2me = process_epi2me()
    print("PROCESSAR CZ.ID")
    czid = process_czid()
    print("\nA guardar Excel...")
    export_excel(epi2me, czid)
    print("\nConcluído!")
    print(f"Ficheiro criado: {OUTPUT_FILE}")
if __name__ == "__main__":
    main()
