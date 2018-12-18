library(ade4)

normalized=read.table("/databis/hilpert/resultsPlasAbund/abundance_matrix/abundance.normalized.matrix",header=TRUE,sep="\t") 
normalized_matrix=data.matrix(normalized)
normalized_t=t(normalized_matrix) 
colnames(normalized_t)=normalized$Features
normalized_t=normalized_t[3:nrow(normalized_t),]
z=dudi.pca(df = normalized_t, scannf = FALSE, nf = 2)
inertie=z$eig/sum(z$eig)*100
cl1=z$li[,1]
cl2=z$li[,2] 
rownames(z$li)=c("Biofilm","STEP1","Pavin","STEP2","Feces1","Feces2")

pdf("/databis/hilpert/resultsPlasAbund/abundance_matrix/abundance.normalized.eigenVal.pdf") 
barplot(inertie) 
dev.off() 

pdf("/databis/hilpert/resultsPlasAbund/abundance_matrix/abundance.normalized.acp.pdf") 
plot(cl1,cl2,xlim=c(-300,450),ylim=c(-300,350)) 
text(cl1,cl2+15,rownames(z$li)) 
dev.off() 
