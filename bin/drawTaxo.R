library(ggplot2) 

biofilm=read.table("/databis/hilpert/resultsPlasTaxo/NG-14342_NG-17411_BIOFILM.megahit.taxo.predicted_plasmids",sep="\t") 
step2=read.table("/databis/hilpert/resultsPlasTaxo/NG-18198_STEP10.megahit.taxo.predicted_plasmids",sep="\t") 
feces1=read.table("/databis/hilpert/resultsPlasTaxo/NG-18198_Fe1210.megahit.taxo.predicted_plasmids",sep="\t") 
pavin=read.table("/databis/hilpert/resultsPlasTaxo/NG-18198_Pavin10.megahit.taxo.predicted_plasmids",sep="\t") 
feces2=read.table("/databis/hilpert/resultsPlasTaxo/NG-18198_FeGe10.megahit.taxo.predicted_plasmids",sep="\t") 
step1=read.table("/databis/hilpert/resultsPlasTaxo/NG-14342_NG-17411_WWTP2.megahit.taxo.predicted_plasmids",sep="\t")

biofilm$Sample="Biofilm" 
step2$Sample="STEP2" 
feces1$Sample="Feces1" 
pavin$Sample="Pavin" 
feces2$Sample="Feces2" 
step1$Sample="STEP1" 

taxo_plasmids=rbind(biofilm,step2,feces1,pavin,feces2,step1) 
colors=c("#EB466E", "#62c36e", "#ffe746", "#6882df", "#f79b5a", "#a74ac3", "#67dcf6", "#f35aeb")

taxoPerc=ggplot(taxo_plasmids,aes(x=Sample,fill=V2))+geom_bar(position="fill")+scale_fill_manual(values=colors)+scale_y_continuous(labels=scales::percent)+labs(fill="Taxon",y="% taxon")+theme(legend.text=element_text(size=14),legend.title=element_text(size=16),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

taxoCount=ggplot(taxo_plasmids,aes(x=Sample,fill=V2))+geom_bar()+scale_fill_manual(values=colors)+labs(fill="Taxon",y="Number of contigs")+theme(legend.text=element_text(size=14),legend.title=element_text(size=16),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))

pdf("/databis/hilpert/resultsPlasTaxo/taxo_percent.pdf",width=10)
taxoPerc
dev.off() 

pdf("/databis/hilpert/resultsPlasTaxo/taxo_count.pdf",width=10) 
taxoCount 
dev.off() 

save.image(file="/databis/hilpert/R_images/taxo.Rdata") 
