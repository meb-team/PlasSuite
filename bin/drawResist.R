library(ggplot2) 

relative_catAb=read.table("/databis/hilpert/resultsPlasResist/abundance_matrix/resistance_matrix.relative.matrix.sum.catAb.format",header=TRUE,sep="\t")
normalized_catAb=read.table("/databis/hilpert/resultsPlasResist/abundance_matrix/resistance_matrix.normalized.matrix.sum.catAb.format",header=TRUE,sep="\t")
relative_catAb$Sample=factor(relative_catAb$Sample,levels=c("NG-14342_NG-17411_BIOFILM.sorted","NG-14342_NG-17411_WWTP2.sorted","NG-18198_STEP10.sorted","NG-18198_FeGe10.sorted","NG-18198_Fe1210.sorted","NG-18198_Pavin10.sorted"))
normalized_catAb$Sample=factor(normalized_catAb$Sample,levels=c("NG-14342_NG-17411_BIOFILM.sorted","NG-14342_NG-17411_WWTP2.sorted","NG-18198_STEP10.sorted","NG-18198_FeGe10.sorted","NG-18198_Fe1210.sorted","NG-18198_Pavin10.sorted"))

normalized_profile=read.table("/databis/hilpert/resultsPlasResist/abundance_matrix/resistance_matrix.normalized.matrix.sum.ResfamsProfile.morePresent",header=TRUE)
normalized_profile$Sample=factor(normalized_profile$Sample,levels=c("NG-14342_NG-17411_BIOFILM.sorted","NG-14342_NG-17411_WWTP2.sorted","NG-18198_STEP10.sorted","NG-18198_Fe1210.sorted","NG-18198_FeGe10.sorted","NG-18198_Pavin10.sorted"))
relative_profile=read.table("/databis/hilpert/resultsPlasResist/abundance_matrix/resistance_matrix.relative.matrix.sum.ResfamsProfile.morePresent",header=TRUE,sep="\t")
relative_profile$Sample=factor(relative_profile$Sample,levels=c("NG-14342_NG-17411_BIOFILM.sorted","NG-14342_NG-17411_WWTP2.sorted","NG-18198_STEP10.sorted","NG-18198_Fe1210.sorted","NG-18198_FeGe10.sorted","NG-18198_Pavin10.sorted"))

colors_catAb=c("#EB466E", "#62c36e", "#ffe746", "#6882df", "#f79b5a", "#a74ac3", "#67dcf6", "#f35aeb","#bfef45","#fabebe","#469990","#e6beff","#9A6324","#fffac8","#800000","#aaffc3")
colors_profile=c("grey","#EB466E", "#62c36e", "#ffe746", "#6882df", "#f79b5a", "#a74ac3", "#67dcf6", "#f35aeb","#bfef45","#fabebe","#469990")


plot_relative_catAb=ggplot(relative_catAb,aes(x=Sample,y=Count,fill=Profile))+geom_bar(stat="identity")+scale_x_discrete(labels=c("Biofilm","STEP1","STEP2","Feces1","Feces2","Pavin"))+scale_fill_manual(values=colors_catAb)+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),axis.title.y=element_text(size=16),axis.text.y=element_text(size=14))+labs(fill="Resfams description",y="Number of reads mapped / Number of total reads mapped")  

plot_normalized_catAb=ggplot(normalized_catAb,aes(x=Sample,y=Count,fill=Profile))+geom_bar(stat="identity")+scale_x_discrete(labels=c("Biofilm","STEP1","STEP2","Feces1","Feces2","Pavin"))+scale_fill_manual(values=colors_catAb)+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),axis.title.y=element_text(size=16),axis.text.y=element_text(size=14))+labs(fill="Resfams description",y="(Number of reads mapped / Number of total reads in library) * 1e6")

plot_relative_profile=ggplot(relative_profile,aes(x=Sample,y=Count,fill=Profile))+geom_bar(stat="identity")+scale_x_discrete(labels=c("Biofilm","STEP1","STEP2","Feces1","Feces2","Pavin"))+scale_fill_manual(values=colors_profile)+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),axis.title.y=element_text(size=16),axis.text.y=element_text(size=14))+labs(fill="Resfams profile",y="Number of reads mapped / Number of total reads mapped")

plot_normalized_profile=ggplot(normalized_profile,aes(x=Sample,y=Count,fill=Profile))+geom_bar(stat="identity")+scale_x_discrete(labels=c("Biofilm","STEP1","STEP2","Feces1","Feces2","Pavin"))+scale_fill_manual(values=colors_profile)+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),legend.title=element_text(size=16),legend.text=element_text(size=14),axis.title.y=element_text(size=16),axis.text.y=element_text(size=14))+labs(fill="Resfams profile",y="(Number of reads mapped / Number of total reads in library) * 1e6")

pdf("/databis/hilpert/resultsPlasResist/abundance_matrix/resistances.relative.catAb.pdf",width=10) 
plot_relative_catAb 
dev.off() 
pdf("/databis/hilpert/resultsPlasResist/abundance_matrix/resistances.normalized.catAb.pdf",width=10) 
plot_normalized_catAb 
dev.off() 
pdf("/databis/hilpert/resultsPlasResist/abundance_matrix/resistances.relative.ResfamsProfile.pdf") 
plot_relative_profile
dev.off() 
pdf("/databis/hilpert/resultsPlasResist/abundance_matrix/resistances.normalized.ResfamsProfile.pdf") 
plot_normalized_profile
dev.off() 

save.image(file="/databis/hilpert/R_images/resistances.Rdata") 
