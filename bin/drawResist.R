library(ggplot2) 

matrix_catAb=read.table("/databis/hilpert/resultsPlasAbund/abundance_matrix/resistances_abundance.matrix.sum.catAb.format",header=TRUE,sep="\t")
matrix_profile=read.table("/databis/hilpert/resultsPlasAbund/abundance_matrix/resistances_abundance.matrix.sum.ResfamsProfile.morePresent",header=TRUE,sep="\t") 

lib_step1=15567355126
lib_step2=5824867729
lib_biofilm=21364916801
lib_pavin=5216426935
lib_feces1=4688072460
lib_feces2=3912714182

matrix_catAb$Sample=factor(matrix_catAb$Sample,levels=c("NG-14342_NG-17411_BIOFILM.sorted.markdup.sorted","NG-14342_NG-17411_WWTP2.sorted.markdup.sorted","NG-18198_STEP10.sorted.markdup.sorted","NG-18198_FeGe10.sorted.markdup.sorted","NG-18198_Fe1210.sorted.markdup.sorted","NG-18198_Pavin10.sorted.markdup.sorted"))
matrix_profile$Sample=factor(matrix_profile$Sample,levels=c("NG-14342_NG-17411_BIOFILM.sorted.markdup.sorted","NG-14342_NG-17411_WWTP2.sorted.markdup.sorted","NG-18198_STEP10.sorted.markdup.sorted","NG-18198_FeGe10.sorted.markdup.sorted","NG-18198_Fe1210.sorted.markdup.sorted","NG-18198_Pavin10.sorted.markdup.sorted"))

matrix_catAb$Perc=matrix_catAb$Count/ave(matrix_catAb$Count,matrix_catAb$Sample,FUN=sum)
matrix_profile$Perc=matrix_profile$Count/ave(matrix_profile$Count,matrix_profile$Sample,FUN=sum)  

colors_catAb=c("#EB466E", "#62c36e", "#ffe746", "#6882df", "#f79b5a", "#a74ac3", "#67dcf6", "#f35aeb","#bfef45","#fabebe","#469990","#e6beff","#9A6324","#fffac8","#800000","#aaffc3")
colors_profile=c("grey","#EB466E", "#62c36e", "#ffe746", "#6882df", "#f79b5a", "#a74ac3", "#67dcf6", "#f35aeb","#bfef45","#fabebe","#469990")

plot_relative_catAb=ggplot(matrix_catAb,aes(x=Sample,y=Perc,fill=Profile))+geom_bar(stat="identity")+scale_x_discrete(labels=c("Biofilm","STEP1","STEP2","Feces1","Feces2","Pavin"))+scale_fill_manual(values=colors_catAb)+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),axis.title.y=element_text(size=16),axis.text.y=element_text(size=14))+labs(fill="Resfams description",y="Number of reads mapped / Number of total reads mapped") 
plot_normalized_catAb=ggplot(matrix_catAb,aes(x=Sample,y=Count/Library_size*1e6,fill=Profile))+geom_bar(stat="identity")+scale_x_discrete(labels=c("Biofilm","STEP1","STEP2","Feces1","Feces2","Pavin"))+scale_fill_manual(values=colors_catAb)+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),axis.title.y=element_text(size=16),axis.text.y=element_text(size=14))+labs(fill="Resfams description",y="(Number of reads mapped / Number of total reads in library) * 1e6")

plot_relative_profile=ggplot(matrix_profile,aes(x=Sample,y=Perc,fill=Profile))+geom_bar(stat="identity")+scale_x_discrete(labels=c("Biofilm","STEP1","STEP2","Feces1","Feces2","Pavin"))+scale_fill_manual(values=colors_profile)+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),axis.title.y=element_text(size=16),axis.text.y=element_text(size=14))+labs(fill="Resfams profile",y="Number of reads mapped / Number of total reads mapped")
plot_normalized_profile=ggplot(matrix_profile,aes(x=Sample,y=Count/Library_size*1e6,fill=Profile))+geom_bar(stat="identity")+scale_x_discrete(labels=c("Biofilm","STEP1","STEP2","Feces1","Feces2","Pavin"))+scale_fill_manual(values=colors_profile)+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),axis.title.y=element_text(size=16),axis.text.y=element_text(size=14))+labs(fill="Resfams profile",y="Number of reads mapped / Number of total reads mapped")


pdf("/databis/hilpert/resultsPlasAbund/abundance_matrix/resistances.relative.catAb.pdf",width=10) 
plot_relative_catAb 
dev.off() 
pdf("/databis/hilpert/resultsPlasAbund/abundance_matrix/resistances.normalized.catAb.pdf",width=10) 
plot_normalized_catAb 
dev.off() 
pdf("/databis/hilpert/resultsPlasAbund/abundance_matrix/resistances.relative.ResfamsProfile.pdf") 
plot_relative_profile
dev.off() 
pdf("/databis/hilpert/resultsPlasAbund/abundance_matrix/resistances.normalized.ResfamsProfile.pdf") 
plot_normalized_profile
dev.off() 

save.image(file="/databis/hilpert/R_images/resistances.Rdata") 
