
################### Install and load required packages ###################
##########################################################################
# Vetor com todos os pacotes exigidos
packages <- c("ggplot2", "vegan", "tidyr", "readxl", "dplyr", "scales", "patchwork", "ggtext")

# Install apenas os pacotes que ainda não estiverem instalados
install.packages(setdiff(packages, rownames(installed.packages())))

# Load the packages
library(readxl)     # Lê ficheiros excel
library(vegan)      # Para análise ecológica
library(tidyr)      # Restruturação de dados
library(dplyr)      # Transformação de dados
library(ggplot2)    # Cria gráficos
library(scales)     # Escalas para ggplot2
library(patchwork)  # Composição do plot
library(ggtext)     # Formata textos

# Input dos dados
tax <- read_excel("taxonomy.xlsx")


###################### Vírus identificados pelo programa EPI2ME ###########
###########################################################################
# Apenas vírus identificados pelo EPI2ME
viral <- taxonomy |>
  filter(Program == "EPI2ME", Kingdom == "Viruses", Genus != "Unknown", !is.na(Genus), Class != "NA", !is.na(Class), !is.na(Abundance))
viral$Abundance <- as.numeric(viral$Abundance)
# Somar abundâncias das três bases de dados
bubble <- viral |>group_by(Sample, Class, Genus) |>
  summarise(Abundance = sum(Abundance),.groups = "drop")

# Ordem dos Géneros
ordem <- bubble |>group_by(Class, Genus) |>
  summarise(Total = sum(Abundance), .groups = "drop") |>arrange(Class, desc(Total))

bubble$Genus <- factor(bubble$Genus, levels = rev(unique(ordem$Genus)))

# Ordem das amostras
bubble$Sample <- factor(bubble$Sample, levels = c("W-C", "W11", "W12", "W13-4", "W13-7", "W15-5", "W15-8", "W3", "W4", "W7"))

# Gráfico
p<-ggplot(bubble,aes(x = Sample, y = Genus, size = Abundance, colour = Class)) +
  geom_point(alpha = 1.0, stroke = 0.5) +
  scale_size_continuous(
    trans = "log10",
    range = c(2,8),
    name = "Abundância") +
  labs(x = "Amostra", y = "Género viral", colour = "Grupo táxon") +
  theme_classic(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45,hjust = 1),
        axis.text.y = element_text(size = 8),
        legend.position = "right",
        legend.title = element_text(face = "bold"))
p
ggsave("Bubble_plot_virus.pdf", plot = p, width = 10, height = 8)

################### Indíces Simpson, Shannon e Richeness ##################
################### pelo programa EPI2ME ##################################
###########################################################################
pluspf_db <- diversity_pluspf |> 
  filter(Indices == "Richness" | Indices == "Shannon diversity index" | Indices == "Simpson's index"
  ) |>mutate(BaseDados = "PlusPF")

standard_db <- diversity_standard |>
  filter(Indices == "Richness" | Indices == "Shannon diversity index" | Indices == "Simpson's index"
  ) |> mutate(BaseDados = "Standard")

viral_db <- diversity_viral |>
  filter(Indices == "Richness" | Indices == "Shannon diversity index" | Indices == "Simpson's index"
  ) |> mutate(BaseDados = "Viral")

diversity <- bind_rows(standard_db, pluspf_db, viral_db)

# Formato longo
diversity_long <- diversity |> pivot_longer(
  cols = c("W-C", "W11", "W12", "W13-4", "W13-7", "W15-5", "W15-8", "W3", "W4", "W7"), 
  names_to = "Sample", values_to = "Value")

# Converter valores
diversity_long$Value <- as.numeric(diversity_long$Value)

# Ordem das amostras
diversity_long$Sample <- factor(
  diversity_long$Sample,
  levels = c("W-C", "W11", "W12", "W13-4", "W13-7", "W15-5", "W15-8", "W3", "W4", "W7"))

## Richness
p1 <- ggplot(
  filter(diversity_long, Indices == "Richness"),
  aes(x = Sample, y = Value, fill = BaseDados)) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7) +
  scale_fill_manual(
    values = c(
      "Standard" = "#1B9E77",
      "PlusPF" = "#8E44AD",
      "Viral" = "#0072B2")) +
  labs(x = "Amostra", y = "Richness", fill = "Base de dados") +
  theme_classic(base_size = 14) +
  theme(
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top",
    legend.title = element_text(face = "bold"))
p1
ggsave("Richeness.pdf", plot = p1, width = 8, height = 6)

## Shannon
p2 <- ggplot(
  filter(diversity_long, Indices == "Shannon diversity index"),
  aes(x = Sample, y = Value, fill = BaseDados)) +
  geom_bar(
    stat = "identity",
    position = position_dodge(),
    width = 0.8) +
  scale_fill_manual(
    values = c(
      "Standard" = "#1B9E77",
      "PlusPF" = "#8E44AD",
      "Viral" = "#0072B2")) +
  labs(x = "Amostra", y = "Índice Shannon", fill = "Base de dados") +
  theme_classic(base_size = 14) +
  theme(
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top",
    legend.title = element_text(face = "bold"))
p2
ggsave("Shannon.pdf", plot = p2, width = 8, height = 6)

## Simpson
p3 <- ggplot(
  filter(diversity_long, Indices == "Simpson's index"),
  aes(x = Sample, y = Value, fill = BaseDados)) +
  geom_bar(
    stat = "identity",
    position = position_dodge(),
    width = 0.8) +
  scale_fill_manual(
    values = c(
      "Standard" = "#1B9E77",
      "PlusPF" = "#8E44AD",
      "Viral" = "#0072B2")) +
  labs(x = "Amostra", y = "Índice Simpson", fill = "Base de dados") +
  theme_classic(base_size = 14) +
  theme(
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top",
    legend.title = element_text(face = "bold"))
p3
ggsave("Simpson.pdf", plot = p3, width = 8, height = 6)



################### Nº de espécies únicas de vírus e bactérias ##########
################### que foram identificadas por cada programa ###########
#########################################################################
taxonomy |> filter(
    (Program == "CZ.ID" | Program == "EPI2ME") &
      (Kingdom == "Viruses" | Kingdom == "Bacteria")) |>
  distinct(Program,Kingdom,Species) |>
  count(Program,Kingdom,name = "Unique_species")


################### Nº de espécies únicas de vírus, bactérias ###########
################### e eucariotas patogénos do CZ.ID #####################
#########################################################################
taxonomy |> filter(Program == "CZ.ID", known_pathogen == "Yes",
    (Kingdom == "Viruses" | Kingdom == "Bacteria" | Kingdom == "Eukaryota")) |> 
  distinct(Kingdom, Species) |>
  count(Kingdom,name = "Unique_pathogenic_species")


################### Presença de bacteriófagos nas amostras ################
################### identificados pelo programa CZ.ID #####################
###########################################################################
# Filtrar apenas vírus do CZ.ID
viral <- filter(tax, Program == "CZ.ID", Kingdom == "Viruses")

# Remover entradas que não são géneros virais
# Nomes que não correspondem a géneros de bacteriófagos
excluir <- c(
  "Acinetobacter",
  "Ackermannviridae",
  "Aeromonas",
  "Bacteriophage",
  "Bacteroides",
  "Caudoviricetes",
  "Clostridium",
  "Elizabethkingia",
  "Enterococcus",
  "Flavobacterium",
  "Herelleviridae",
  "Inoviridae",
  "Klebsiella",
  "Lactococcus",
  "Microviridae",
  "Microvirus",
  "Paenibacillus",
  "Phage",
  "Phocaeicola",
  "Prevotella",
  "Providencia",
  "Pseudaeromonas",
  "Ralstonia",
  "Rattus",
  "Staphylococcus",
  "Streptococcus",
  "Tortoise",
  "uncultured",
  "Yersinia")

# Filtrar apenas os géneros de bacteriófagos
phage_matrix <- filter(viral, is_phage == "Yes", is.na(match(Genus, excluir)))

# Manter apenas Genus e Sample únicos
phage_matrix <- distinct(phage_matrix, Genus, Sample)

# Criar coluna de presença
phage_matrix$Presente <- 1

# Completar combinações ausentes
phage_matrix <- complete(
  phage_matrix,
  Genus,
  Sample,
  fill = list(Presente = 0))

# Ordenar alfabeticamente
genus_order <- sort(unique(phage_matrix$Genus))

phage_matrix$Genus <- factor(
  phage_matrix$Genus,
  levels = rev(genus_order))

# Tema
tema_heatmap <- theme_classic(base_size = 14) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
    axis.text.y = element_text(face = "italic", size = 8),
    axis.title = element_text(face = "bold"),
    legend.position = "top")

# Gráfico
fig2 <- ggplot(
  phage_matrix,
  aes(x = Sample, y = Genus, fill = factor(Presente))) +
  geom_tile(colour = "grey80", linewidth = 0.3) +
  scale_fill_manual(
    values = c("0" = "white", "1" = "#1F78B4"),
    labels = c("Ausente", "Presente"),
    name = "") +
  labs(
    x = "Amostra",
    y = "Género de bacteriófago") +
  tema_heatmap

fig2

ggsave("presenca_bacteriofagos_czid.pdf", plot = fig2, width = 8, height = 9)

###################### Bactérias patógenicos identificadas ###############
###################### pelo programa CZ.ID ###############################
##########################################################################
freq <- taxonomy |>filter(Program == "CZ.ID", known_pathogen == "Yes", Kingdom == "Bacteria") |>
  count(Genus, sort = TRUE) |> slice_head(n = 30)

# Dados para o heatmap
heat <- taxonomy |>  filter(Program == "CZ.ID", known_pathogen == "Yes", Kingdom == "Bacteria") |>
  distinct(Sample, Kingdom, Genus) |>inner_join(freq, by = "Genus")

# Ordem das amostras
heat$Sample <- factor(heat$Sample,
  levels = c("W-C", "W11", "W12", "W13-4", "W13-7", "W15-5", "W15-8", "W3", "W4", "W7"))

# Ordem das espécies
heat <- heat |> arrange(Genus)

heat$Genus <- factor(heat$Genus, levels = rev(unique(heat$Genus)))

# Gráfico
p5<-ggplot(heat, aes(x = Sample, y = Genus)) +
  geom_tile(fill = "#009E73", colour = "white", linewidth = 0.5) +
  labs(x = "Amostra", y = "Géneros bacterianos patogénicos") +
  theme_classic(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_text(size = 7),
        axis.title = element_text(face = "bold"))
p5
ggsave("bacterias_patogenicas_czid.pdf", plot = p5, width = 8, height = 6)


################### Eucariotas e Vírus patogénicos CZ.ID ##################
###########################################################################
# Dados
heat <- taxonomy |>filter(Program == "CZ.ID", known_pathogen == "Yes",
    (Kingdom == "Viruses" | Kingdom == "Eukaryota")
  ) |>distinct(Sample, Kingdom, Genus)

# Ordem das amostras
heat$Sample <- factor(heat$Sample,
  levels = c("W-C", "W11", "W12", "W13-4", "W13-7", "W15-5", "W15-8", "W3", "W4", "W7"))

# Ordem das espécies
heat <- heat |>arrange(Kingdom, Genus)
heat$Genus <- factor(heat$Genus,levels = rev(unique(heat$Genus)))

# Gráfico
p6<-ggplot(heat,aes(x = Sample, y = Genus, fill = Kingdom)) +
  geom_tile(colour = "white", linewidth = 0.5) +
  facet_grid(Kingdom ~ .,scales = "free_y", space = "free_y") +
  scale_fill_manual(values = c("Viruses" = "#0072B2", "Eukaryota" = "#8E44AD"),
    labels = c("Viruses" = "Vírus", "Eukaryota" = "Eucariotas"), name = "Grupo taxonómico") +
  labs(x = "Amostra", y = "Táxon patogénico") +
  theme_classic(base_size = 14) +
  theme(strip.background = element_blank(),
    strip.text.y = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_text(size = 7),
    axis.title = element_text(face = "bold"),
    legend.position = "top",
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(size = 11),
    guides(fill = guide_legend(title.position = "top", nrow = 1, byrow = TRUE)))
p6
ggsave("eucariotas_virus_patogenicos.pdf", plot = p6, width = 8, height = 6)


################# Teste Não Paramétrico Wilcoxon ###################
####################################################################
# Número de espécies por amostra e plataforma
species_por_amostra <- tax %>%
  filter(
    !is.na(Species),
    Species != "",
    Species != "Unknown"
  )%>%
  group_by(Sample, Program) %>%
  summarise(
    Nspecies = n_distinct(Species),
    .groups = "drop")

species_por_amostra

# Comparação entre EPI2ME e CZ.ID
comparacao <- species_por_amostra %>%
  pivot_wider(names_from = Program, values_from = Nspecies)

comparacao

# Remove amostras que não têm resultados
comparacao_wilcoxon <- comparacao %>%
  filter(!is.na(CZ.ID), !is.na(EPI2ME))

# Teste de Wilcoxon 
wilcox.test(comparacao_wilcoxon$CZ.ID, comparacao_wilcoxon$EPI2ME, paired = TRUE)

# Para Bactérias
bacteria_por_amostra <- tax %>%
  filter(
    Kingdom == "Bacteria",
    !is.na(Species),
    Species != "",
    Species != "Unknown"
  ) %>%
  group_by(Sample, Program) %>%
  summarise(
    Nspecies = n_distinct(Species),
    .groups = "drop")

bacteria_comparacao <- bacteria_por_amostra %>%
  tidyr::pivot_wider(names_from = Program, values_from = Nspecies)

bacteria_comparacao

bacteria_wilcoxon <- bacteria_comparacao %>%
  filter(!is.na(CZ.ID), !is.na(EPI2ME))

wilcox.test(bacteria_wilcoxon$CZ.ID, bacteria_wilcoxon$EPI2ME, paired = TRUE)

# Para Vírus
virus_por_amostra <- tax %>%
  filter(
    Kingdom == "Viruses",
    !is.na(Species),
    Species != "",
    Species != "Unknown"
  ) %>%
  group_by(Sample, Program) %>%
  summarise(
    Nspecies = n_distinct(Species),
    .groups = "drop")

virus_comparacao <- virus_por_amostra %>%
  tidyr::pivot_wider(names_from = Program, values_from = Nspecies)

virus_comparacao

virus_wilcoxon <- virus_comparacao %>%
  filter(!is.na(CZ.ID), !is.na(EPI2ME))

wilcox.test(virus_wilcoxon$CZ.ID, virus_wilcoxon$EPI2ME, paired = TRUE)




