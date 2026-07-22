
################### Instala e descarrega os pacotes exigidos #############
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
ggplot(bubble,aes(x = Sample, y = Genus, size = Abundance, colour = Class)) +
  geom_point(alpha = 1.0, stroke = 0.5) +
  scale_size_continuous(
    trans = "log10",
    range = c(2,8),
    name = "Abundância") +
  labs(x = "Amostra", y = "Género viral", colour = "Grupo taxón") +
  theme_classic(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45,hjust = 1),
        axis.text.y = element_text(size = 8),
        legend.position = "right",
        legend.title = element_text(face = "bold"))


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
ggplot(filter(diversity_long, Indices == "Richness"),
       aes(x = Sample, y = Value, colour = BaseDados, group = BaseDados)) +
  geom_point(size = 3.5) +
  geom_line(linewidth = 1) +
  scale_colour_manual(
    values = c("Standard" = "#1B9E77", "PlusPF" = "#8E44AD", "Viral" = "#0072B2")) +
  labs(x = "Amostra", y = "Richness", colour = "Base de dados") +
  theme_classic(base_size = 14) +
  theme(axis.title = element_text(face = "bold"),
        axis.text = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top",
        legend.title = element_text(face = "bold"))

## Shannon
ggplot(filter(diversity_long, Indices == "Shannon diversity index"),
       aes(x = Sample, y = Value, colour = BaseDados, group = BaseDados)) +
  geom_point(size = 3.5) +
  geom_line(linewidth = 1) +
  scale_colour_manual(
    values = c("Standard" = "#1B9E77", "PlusPF" = "#8E44AD", "Viral" = "#0072B2")) +
  labs(x = "Amostra", y = "Índice Shannon diversity", colour = "Base de dados") +
  theme_classic(base_size = 14) +
  theme(axis.title = element_text(face = "bold"),
        axis.text = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top",
        legend.title = element_text(face = "bold"))

## Simpson
ggplot(filter(diversity_long, Indices == "Simpson's index"),
       aes(x = Sample, y = Value, colour = BaseDados, group = BaseDados)) +
  geom_point(size = 3.5) +
  geom_line(linewidth = 1) +
  scale_colour_manual(
    values = c("Standard" = "#1B9E77", "PlusPF" = "#8E44AD", "Viral" = "#0072B2")) +
  labs(x = "Amostra", y = "Índice Simpson", colour = "Base de dados") +
  theme_classic(base_size = 14) +
  theme(axis.title = element_text(face = "bold"),
        axis.text = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top",
        legend.title = element_text(face = "bold"))


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


################### Nº de Bacteriófagos e Não Bacteriófagos ############# 
################### identificados pelo programa CZ.ID ###################
#########################################################################
# Filtrar apenas CZ.ID e vírus
viral <- filter(tax, Program == "CZ.ID", Kingdom == "Viruses")

# Criar coluna Grupo
viral$Grupo <- ifelse(viral$is_phage == "Yes", "Bacteriófagos", "Não bacteriófagos")

# Contar espécies por amostra e grupo
plot_data <- summarise(group_by(viral, Sample, Grupo), Especies = n_distinct(Species), .groups = "drop")

# Passar para formato largo
plot_data <- pivot_wider(plot_data, names_from = Grupo, values_from = Especies, values_fill = 0)

# Tornar os vírus não bacteriófagos negativos
plot_data$`Não bacteriófagos` <--plot_data$`Não bacteriófagos`

# Gráfico
ggplot(plot_data, aes(y = Sample)) +
  geom_col(aes(x = `Não bacteriófagos`, fill = "Não bacteriófagos"), width = 0.55) +
  geom_col(aes(x = Bacteriófagos, fill = "Bacteriófagos"), width = 0.55) +
  geom_text(aes(x = `Não bacteriófagos`, label = abs(`Não bacteriófagos`)),
    hjust = 1.15,
    size = 4,
    fontface = "bold") +
  geom_text(aes(x = Bacteriófagos, label = Bacteriófagos),
    hjust = -0.15,
    size = 4,
    fontface = "bold") +
  scale_fill_manual(breaks = c("Não bacteriófagos", "Bacteriófagos"),
    values = c("Não bacteriófagos" = "#A6CEE3", "Bacteriófagos" = "#1F78B4"), name = "") +
  scale_x_continuous(labels = abs) +
  labs(x = "Número de espécies virais", y = "Amostra") +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold"),
    legend.position = "top",
    legend.text = element_text(size = 12))


################### Presença de bacteriófagos nas amostras ################
################### identificados pelo programa CZ.ID #####################
###########################################################################

viral <- filter(tax, Program == "CZ.ID", Kingdom == "Viruses")

# Filtrar apenas bacteriófagos
phage_matrix <- filter(viral, is_phage == "Yes")

# Manter apenas Species e Sample únicos
phage_matrix <- distinct(phage_matrix, Genus, Sample)

# Criar coluna de presença
phage_matrix$Presente <- 1

# Completar combinações ausentes
phage_matrix <- complete(phage_matrix, Genus, Sample, fill = list(Presente = 0))

# Ordenar alfabeticamente
genus_order <- sort(unique(phage_matrix$Genus))

# Dividir ao meio
metade <- ceiling(length(genus_order) / 2)

# Primeira metade
phage_matrix1 <- phage_matrix[
  !is.na(match(phage_matrix$Genus, genus_order[1:metade])),]

# Segunda metade
phage_matrix2 <- phage_matrix[
  !is.na(match(phage_matrix$Genus,
               genus_order[(metade + 1):length(genus_order)])),]

# Manter a ordem das espécies
phage_matrix1$Genus <- factor(phage_matrix1$Genus,
  levels = rev(genus_order[1:metade]))

phage_matrix2$Genus <- factor(phage_matrix2$Genus,
  levels = rev(genus_order[(metade + 1):length(genus_order)]))

tema_heatmap <- theme_classic(base_size = 14) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
    axis.text.y = element_text(face = "italic", size = 7),
    legend.position = "top")

fig2A <- ggplot(phage_matrix1, aes(x = Sample, y = Genus, fill = factor(Presente))) +
  geom_tile(colour = "grey80", linewidth = 0.3) +
  scale_fill_manual(values = c("0" = "white", "1" = "#1F78B4"), labels = c("Ausente", "Presente"), name = "") +
  labs( x = "Amostra", y = "Bacteriófago") +
  tema_heatmap
fig2A

fig2B <- ggplot(phage_matrix2, aes(x = Sample, y = Genus, fill = factor(Presente))) +
  geom_tile(colour = "grey80", linewidth = 0.3) +
  scale_fill_manual(values = c("0" = "white", "1" = "#1F78B4"),labels = c("Ausente", "Presente"), name = "") +
  labs(x = "Amostra", y = "Bacteriófago") +
  tema_heatmap
fig2B


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
ggplot(heat, aes(x = Sample, y = Genus)) +
  geom_tile(fill = "#009E73", colour = "white", linewidth = 0.5) +
  labs(x = "Amostra", y = "Géneros bacterianos patogénicos") +
  theme_classic(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_text(size = 7),
        axis.title = element_text(face = "bold"))


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
ggplot(heat,aes(x = Sample, y = Genus, fill = Kingdom)) +
  geom_tile(colour = "white", linewidth = 0.5) +
  facet_grid(Kingdom ~ .,scales = "free_y", space = "free_y") +
  scale_fill_manual(values = c("Viruses" = "#0072B2", "Eukaryota" = "#8E44AD"),
    labels = c("Viruses" = "Vírus", "Eukaryota" = "Eucariotas"), name = "Grupo taxonómico") +
  labs(x = "Amostra", y = "Género patogénico") +
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
