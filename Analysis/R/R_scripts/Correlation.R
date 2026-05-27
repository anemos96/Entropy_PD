############# Pearson Correlation ###############
#################################################
#################################################
# Author: Ettore Napoli
# Date: February 2026
# Dependencies: tidyverse, Hmisc, readxl, ggpubr

# Install packages
install.packages('tidyverse');
install.packages('Hmisc');
install.packages('ggpubr')
library(readxl);
library(tidyverse);
library(Hmisc);
library(ggpubr)

# Load custom func
source("Custom_Function/flattenCorrMatrix.R")

# Load data
data = read_xlsx('Data_Table.xlsx');
data = data.frame(data);

# Set factor variables
data$ID <- as.factor(data$ID);

# Set numerical variables
data$TMT_BA = as.numeric(data$TMT_BA);
data$MFPI_Flessibilità = as.numeric(data$MFPI_Flessibilità);
data$MFPI_Inflessibilità = as.numeric(data$MFPI_Inflessibilità);

# Discard rows with NAs
data = na.omit(data);

# Get dataframe without demographics
data_noDemo = data %>%
  select(- ID, - Età, - Scolarità);

data_poster = data_noDemo %>%
  select(-CRI_tot, -SW_SampEN_Ant_alpha, -SW_SampEN_Post_alpha, 
         -SW_SampEN_Ant_beta, -SW_SampEN_Post_beta, -SW_SampEN_Ant_delta, 
         -SW_SampEN_Post_delta, -SW_SampEN_Ant_theta, -SW_SampEN_Post_theta, -ApEN_Post_alpha,
         -ApEN_Post_beta, -ApEN_Post_delta, -ApEN_Post_theta, -MSE_Post_alpha,
         -MSE_Post_beta, -MSE_Post_delta, -MSE_Post_theta);

# Check for gaussianity (if normal, we use pearson, otherwise Spearman)
shapiro.test(data_noDemo$CRI_tot); #Normal
shapiro.test(data_noDemo$MOCA_tot); #Normal
shapiro.test(data_noDemo$TMT_BA); #Not normal. We will use spearman

# Run Correlations
corr_results <- rcorr(as.matrix(data_noDemo), type = "spearman");
corr_results_poster <- rcorr(as.matrix(data_poster), type = "spearman");

# Get Spearman r and pvalues matrices
r_matrix <- corr_results$r;
p_matrix <- corr_results$P;
r_matrix_poster <- corr_results_poster$r;
p_matrix_poster <- corr_results_poster$P;

# Let's flatten the result matrix for better visualization
corr_flat <- flattenCorrMatrix(r_matrix, p_matrix);
corr_flat_poster <- flattenCorrMatrix(r_matrix_poster, p_matrix_poster); 
  

# Filter for p<0.05
corr_flat_sig <- corr_flat %>%
  filter(p < 0.05) 

corr_flat_sig_poster  <- corr_flat_poster %>%
  filter(p < 0.05)

# Round for readibility
corr_flat_sig$cor <- round(corr_flat_sig$cor, 20);
corr_flat_sig$p <- round(corr_flat_sig$p, 20);
corr_flat_sig_poster$cor <- round(corr_flat_sig_poster$cor, 20);
corr_flat_sig_poster$p <- round(corr_flat_sig_poster$p, 20);

# Save file
write_csv(corr_flat_sig, "Significant_Results.csv");
write_csv(corr_flat_sig_poster, "Significant_Results_Poster.csv");

# FDR correction for multiple comparison
corr_flat$p_adj <- p.adjust(corr_flat$p, method = "fdr");
corr_flat_sig_adj <- corr_flat %>%
  filter(p_adj < 0.05)
corr_flat_poster$p_adj <- p.adjust(corr_flat_poster$p, method = "fdr");
corr_flat_sig_adj_poster <-corr_flat_poster %>%
  filter(p_adj < 0.05);
  

# Save file
write_csv(corr_flat_sig_adj, "Significant_Results_FDR.csv")
write_csv(corr_flat_sig_adj_poster, "Significant_Results_FDR_POSTER.csv");

# Plot
plot_MFPI_theta <- ggscatter(data_noDemo, x = "SW_SampEN_Ant_Theta", y = "MFPI_Inflessibilità", 
          add = "reg.line",                         
          conf.int = TRUE,                          
          cor.coef = FALSE,                          
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
                             cor.coef = FALSE,                          
                             cor.method = "spearman",                  
                             cor.coef.size = 5,                        
                             color = "#2E86C1",                        
                             shape = 21, size = 3, fill = "#AED6F1",
                             xlab = "Beta Band Complexity (ApEn)",       
                             ylab = "Cognitive Inflexibility (MFPI)",          
                             title = "") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) # Centra il titolo

#plot_MFPI_theta_poster <- ggscatter(data_poster, x = "SW_SampEN_Ant_Theta", y = "MFPI_Inflessibilità", 
                             add = "reg.line",                         
                             conf.int = TRUE,                          
                             cor.coef = FALSE,                          
                             cor.method = "spearman",                  
                             cor.coef.size = 5,                        
                             color = "#2E86C1",                        
                             shape = 21, size = 3, fill = "#AED6F1",
                             xlab = "Neural Complexity Dynamics (Theta Band)",       
                             ylab = "Cognitive Inflexibility (MFPI)",          
                             title = "") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

plot_MFPI_beta_poster <- ggscatter(data_poster, x = "ApEN_Ant_Beta", y = "MFPI_Inflessibilità", 
                            add = "reg.line",                         
                            conf.int = TRUE,                          
                            cor.coef = FALSE,                          
                            cor.method = "spearman",                  
                            cor.coef.size = 5,                        
                            color = "#2E86C1",                        
                            shape = 21, size = 3, fill = "#AED6F1",
                            xlab = "Beta Band Complexity (ApEn)",       
                            ylab = "Cognitive Inflexibility (MFPI)",          
                            title = "") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

# Save Plots
ggsave("Figures/MFPI_theta.png", plot = plot_MFPI_theta, bg = "white")
ggsave("Figures/MFPI_beta.png", plot = plot_MFPI_beta, bg = "white")
#ggsave("Figures/MFPI_theta_poster.png", plot = plot_MFPI_theta_poster, bg = "white")
ggsave("Figures/MFPI_beta_poster.png", plot = plot_MFPI_beta_poster, bg = "white")



