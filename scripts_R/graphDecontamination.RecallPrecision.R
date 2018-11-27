library(ggplot2)
library(svglite)

all_approaches=read.table("/databis/hilpert/plasmidome_project/proper/decontamination/all_approaches.stats",header=TRUE,sep="\t") 
all_approaches$Assembly=c("Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes")
all_approaches$Method=c("Plasflow10","Plasflow20","Plasflow30","Plasflow40","Plasflow50","Plasflow60","Plasflow70","Plasflow80","Plasflow90","cBar + PlasFlow70","cBar + PlasFlow80","cBar + PlasFlow90","cBar","Chromosomes alignment","Chromosomes alignment 99","Chromosomes alignment 97","Chromosomes alignment 95","Chromosomes alignment 90","Plasmids markers","Plasflow10","Plasflow20","Plasflow30","Plasflow40","Plasflow50","Plasflow60","Plasflow70","Plasflow80","Plasflow90","cBar + PlasFlow70","cBar + PlasFlow80","cBar + PlasFlow90","cBar","Chromosomes alignment","Chromosomes alignment 99","Chromosomes alignment 97","Chromosomes alignment 95","Chromosomes alignment 90","Plasmids markers")
all_approaches$Method=factor(all_approaches$Method,levels=c("Plasflow10","Plasflow20","Plasflow30","Plasflow40","Plasflow50","Plasflow60","Plasflow70","Plasflow80","Plasflow90","cBar + PlasFlow70","cBar + PlasFlow80","cBar + PlasFlow90","cBar","Chromosomes alignment","Chromosomes alignment 99","Chromosomes alignment 97","Chromosomes alignment 95","Chromosomes alignment 90","Plasmids markers")) 

plot1=ggplot(all_approaches,aes(x=Precision,y=Recall,shape=Assembly,col=Method))+geom_point(size=3)+scale_colour_manual(values=c("#b2b2ff","#9999ff","#7f7fff","#6666ff","#4c4cff","#3232ff","#0000e5","#0000b2","#00007f","#7fbf7f","#198c19","#005900","orange","#7f0000","#cc0000","#ff1919","#ff4c4c","#ff7f7f","#cc00cc"))+theme(legend.text=element_text(size=14),legend.title=element_text(size=16),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16)) 

megahit=subset(all_approaches,Assembly=="Megahit") 
metaspades=subset(all_approaches,Assembly=="MetaSPAdes") 
plot2=ggplot(megahit,aes(y=F0.5.Score,x=Method,fill=Method))+geom_bar(stat="identity",position="dodge")+scale_fill_manual(values=c("#b2b2ff","#9999ff","#7f7fff","#6666ff","#4c4cff","#3232ff","#0000e5","#0000b2","#00007f","#7fbf7f","#198c19","#005900","orange","#7f0000","#cc0000","#ff1919","#ff4c4c","#ff7f7f","#cc00cc"))+theme(legend.text=element_text(size=14),legend.title=element_text(size=16),axis.text.x=element_blank(),axis.title.x=element_blank(),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),axis.ticks.x=element_blank())+labs(title="Megahit") 
plot3=ggplot(metaspades,aes(y=F0.5.Score,x=Method,fill=Method))+geom_bar(stat="identity",position="dodge")+scale_fill_manual(values=c("#b2b2ff","#9999ff","#7f7fff","#6666ff","#4c4cff","#3232ff","#0000e5","#0000b2","#00007f","#7fbf7f","#198c19","#005900","orange","#7f0000","#cc0000","#ff1919","#ff4c4c","#ff7f7f","#cc00cc"))+theme(legend.text=element_text(size=14),legend.title=element_text(size=16),axis.text.x=element_blank(),axis.title.x=element_blank(),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),axis.ticks.x=element_blank())+labs(title="MetaSPAdes") 

pdf1="/databis/hilpert/plasmidome_project/proper/graphs/decontamination/AllApproaches.Recall.Precision.pdf"
pdf2="/databis/hilpert/plasmidome_project/proper/graphs/decontamination/AllApproaches.Megahit.F05Score.pdf"
pdf3="/databis/hilpert/plasmidome_project/proper/graphs/decontamination/AllApproaches.Metaspades.F05Score.pdf"
svg1="/databis/hilpert/plasmidome_project/proper/graphs/decontamination/AllApproaches.Recall.Precision.svg"
svg2="/databis/hilpert/plasmidome_project/proper/graphs/decontamination/AllApproaches.Megahit.F05Score.svg"
svg3="/databis/hilpert/plasmidome_project/proper/graphs/decontamination/AllApproaches.Metaspades.F05Score.svg"

pdf(pdf1,width=10,height=7)
plot1 
dev.off() 
pdf(pdf2,width=10,height=7) 
plot2
dev.off() 
pdf(pdf3,width=10,height=7) 
plot3
dev.off() 

ggsave(file=svg1,plot=plot1, width=10, height=7)
ggsave(file=svg2,plot=plot2, width=10, height=7)
ggsave(file=svg3,plot=plot3, width=10, height=7)

all_approaches_cov=read.table("/databis/hilpert/plasmidome_project/proper/assembly_evaluation/all_decontamination.tsv",header=TRUE,sep="\t") 
all_approaches_cov$Assembly.type=c("Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","Megahit","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes","MetaSPAdes") 
all_approaches_cov$Method=c("Reference","Plasflow10","Plasflow20","Plasflow30","Plasflow40","Plasflow50","Plasflow60","Plasflow70","Plasflow80","Plasflow90","cBar + PlasFlow70","cBar + PlasFlow80","cBar + PlasFlow90","cBar","Chromosomes alignment","Chromosomes alignment 99","Chromosomes alignment 97","Chromosomes alignment 95","Chromosomes alignment 90","Plasmids markers","Reference","Plasflow10","Plasflow20","Plasflow30","Plasflow40","Plasflow50","Plasflow60","Plasflow70","Plasflow80","Plasflow90","cBar + PlasFlow70","cBar + PlasFlow80","cBar + PlasFlow90","cBar","Chromosomes alignment","Chromosomes alignment 99","Chromosomes alignment 97","Chromosomes alignment 95","Chromosomes alignment 90","Plasmids markers")
all_approaches_cov$Method=factor(all_approaches_cov$Method,levels=c("Plasflow10","Plasflow20","Plasflow30","Plasflow40","Plasflow50","Plasflow60","Plasflow70","Plasflow80","Plasflow90","cBar + PlasFlow70","cBar + PlasFlow80","cBar + PlasFlow90","cBar","Chromosomes alignment","Chromosomes alignment 99","Chromosomes alignment 97","Chromosomes alignment 95","Chromosomes alignment 90","Plasmids markers","Reference")) 

plot=ggplot(all_approaches_cov,aes(x=Contamination.length/Total.length*100,y=X.Plasmids.coverage,shape=Assembly.type,col=Method))+geom_point(size=3)+scale_colour_manual(values=c("#b2b2ff","#9999ff","#7f7fff","#6666ff","#4c4cff","#3232ff","#0000e5","#0000b2","#00007f","#7fbf7f","#198c19","#005900","orange","#7f0000","#cc0000","#ff1919","#ff4c4c","#ff7f7f","#cc00cc","black"))+theme(legend.text=element_text(size=14),legend.title=element_text(size=16),axis.text.x=element_text(size=14),axis.title.x=element_text(size=16),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16))+labs(y="Reference coverage(%)",x="Contamination(%)") 

pdf="/databis/hilpert/plasmidome_project/proper/graphs/decontamination/AllApproaches.Cov.Cont.pdf"
svg="/databis/hilpert/plasmidome_project/proper/graphs/decontamination/AllApproaches.Cov.Cont.svg"

pdf(pdf,height=7,width=10)
plot
dev.off() 
ggsave(file=svg,plot=plot,width=10,height=7) 

megahit=subset(all_approaches_cov,Assembly.type=="Megahit") 
metaspades=subset(all_approaches_cov,Assembly.type=="MetaSPAdes") 
megahit$Method=factor(megahit$Method,levels=c("Reference","Plasflow10","Plasflow20","Plasflow30","Plasflow40","Plasflow50","Plasflow60","Plasflow70","Plasflow80","Plasflow90","cBar + PlasFlow70","cBar + PlasFlow80","cBar + PlasFlow90","cBar","Chromosomes alignment","Chromosomes alignment 99","Chromosomes alignment 97","Chromosomes alignment 95","Chromosomes alignment 90","Plasmids markers")) 
metaspades$Method=factor(metaspades$Method,levels=c("Reference","Plasflow10","Plasflow20","Plasflow30","Plasflow40","Plasflow50","Plasflow60","Plasflow70","Plasflow80","Plasflow90","cBar + PlasFlow70","cBar + PlasFlow80","cBar + PlasFlow90","cBar","Chromosomes alignment","Chromosomes alignment 99","Chromosomes alignment 97","Chromosomes alignment 95","Chromosomes alignment 90","Plasmids markers")) 

ggplot(megahit,aes(y=X.Plasmids.coverage,x=Method,fill=Method))+geom_bar(stat="identity",position="dodge")+scale_fill_manual(values=c("#b2b2ff","#9999ff","#7f7fff","#6666ff","#4c4cff","#3232ff","#0000e5","#0000b2","#00007f","#7fbf7f","#198c19","#005900","orange","#7f0000","#cc0000","#ff1919","#ff4c4c","#ff7f7f","#cc00cc","black"))+theme(legend.text=element_text(size=14),legend.title=element_text(size=16),axis.text.x=element_blank(),axis.title.x=element_blank(),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),axis.ticks.x=element_blank())+labs(title="Megahit") 
ggplot(megahit,aes(y=Contamination.length/Total.length*100,x=Method,fill=Method))+geom_bar(stat="identity",position="dodge")+scale_fill_manual(values=c("#b2b2ff","#9999ff","#7f7fff","#6666ff","#4c4cff","#3232ff","#0000e5","#0000b2","#00007f","#7fbf7f","#198c19","#005900","orange","#7f0000","#cc0000","#ff1919","#ff4c4c","#ff7f7f","#cc00cc","black"))+theme(legend.text=element_text(size=14),legend.title=element_text(size=16),axis.text.x=element_blank(),axis.title.x=element_blank(),axis.text.y=element_text(size=14),axis.title.y=element_text(size=16),axis.ticks.x=element_blank())+labs(title="MetaSPAdes") 
