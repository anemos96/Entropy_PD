#################################################
############### Cluster Analysis ################
#################################################
#################################################
install.packages('tidyverse');
install.packages('Hmisc');
install.packages('ggpubr')
library(readxl);
library(tidyverse);
library(Hmisc);
library(ggpubr)

source("Custom_Function/flattenCorrMatrix.R")


data = read_xlsx('Data_Table.xlsx');
data = data.frame(data);

# Set factor variables
data$ID_soggetto <- as.factor(data$`ID_soggetto`);
data$Genere <- as.factor(data$Genere);

# Set numerical variables
data$TMT_BA = as.numeric(data$TMT_BA);
data$MFPI_Flessibilità = as.numeric(data$MFPI_Flessibilità);
data$MFPI_Inflessibilità = as.numeric(data$MFPI_Inflessibilità);

# Discard rows with NAs
data = na.omit(data);

# Get dataframe without demographics
data_noDemo = data %>%
  select(- ID_soggetto, - Genere, - Età, - Scolarità);

# Check for gaussianity (if normal, we use pearson, otherwise Spearman)
shapiro.test(data_noDemo$CRIq_tot); #Normal
shapiro.test(data_noDemo$MoCA_tot); #Normal
shapiro.test(data_noDemo$TMT_BA); #Not normal. We will use spearman

# Run Correlations
corr_results <- rcorr(as.matrix(data_noDemo), type = "spearman");

# Get Spearman r and pvalues matrices
r_matrix <- corr_results$r;
p_matrix <- corr_results$P;

# Let's flatten the result matrix for better visualization
corr_flat = flattenCorrMatrix(r_matrix, p_matrix);

# Filter for p<0.05
corr_flat_sig <- corr_flat %>%
  filter(p < 0.05) 

# Round for readibility
corr_flat_sig$cor <- round(corr_flat_sig$cor, 20);
corr_flat_sig$p <- round(corr_flat_sig$p, 20);

# Save file
write_csv(corr_flat_sig, "Significant_Results.csv");

# FDR correction for multiple comparison
corr_flat$p_adj <- p.adjust(corr_flat$p, method = "fdr");
corr_flat_sig_adj <- corr_flat %>%
  filter(p_adj < 0.05)

# Save file
write_csv(corr_flat_sig_adj, "Significant_Results_FDR.csv")

# Plot
plot_MFPI_theta <- ggscatter(data_noDemo, x = "SW_SampEN_Ant_Theta", y = "MFPI_Inflessibilità", 
          add = "reg.line",                         
          conf.int = TRUE,                          
          cor.coef = TRUE,                          
          cor.method = "spearman",                  
          cor.coef.size = 5,                        
          color = "#2E86C1",                        
          shape = 21, size = 3, fill = "#AED6F1",
          xlab = "Neural Complexity Dynamics (Theta Band)",       
          ylab = "Cognitive Inflexibility (MFPI)",          
          title = "") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

plot_MFPI_beta <- ggscatter(data_noDemo, x = "ApEN_Ant_Beta", y = "MFPI_Inflessibilità", 
                             add = "reg.line",                         
                             conf.int = TRUE,                          
                             cor.coef = TRUE,                          
                             cor.method = "spearman",                  
                             cor.coef.size = 5,                        
                             color = "#2E86C1",                        
                             shape = 21, size = 3, fill = "#AED6F1",
                             xlab = "Beta Band Complexity (ApEn)",       
                             ylab = "Cognitive Inflexibility (MFPI)",          
                             title = "") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) # Centra il titolo

# Save
ggsave("Figures/MFPI_theta.png", plot = plot_MFPI_theta, bg = "white")
ggsave("Figures/MFPI_beta.png", plot = plot_MFPI_beta, bg = "white")

