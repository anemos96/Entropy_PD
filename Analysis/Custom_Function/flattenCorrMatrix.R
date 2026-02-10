# Flatten correlation matrix obtained by using rcorr()

flattenCorrMatrix = function(cormat,pmat) {
  upper_tri <- upper.tri(cormat)
  data.frame(
    Var1 = rownames(cormat)[row(cormat)[upper_tri]], 
    Var2 = rownames(cormat)[col(cormat)[upper_tri]], 
    cor = cormat[upper_tri], 
    p = pmat[upper_tri])
}