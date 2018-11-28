library(ggplot2)
library(svglite)
library(grid) 
library(ggpubr)

args = commandArgs(trailingOnly=TRUE) 

if (length(args)!=5) {
  stop("usage : RScript --vanilla graphs.R <length file> <contigs file> <plasmids file> <outdir> <prefix>", call.=FALSE)
}


outputName <- function(outdir,prefix,suffix){
	g=paste(outdir,prefix,sep="/")
	g=paste(g,suffix,sep="") 
	return(g)   
}

f=read.table(args[1],header=TRUE,sep="\t")
f_contigs=read.table(args[2],header=TRUE,sep="\t")
f_plasmids=read.table(args[3],header=TRUE,sep="\t")
f$Illumina.coverage=factor(f$Illumina.coverage,levels=c("1X","2X","5X","10X","20X")) 
f_contigs$Illumina.coverage=factor(f_contigs$Illumina.coverage,levels=c("1X","2X","5X","10X","20X")) 
f_plasmids$Illumina.coverage=factor(f_plasmids$Illumina.coverage,levels=c("1X","2X","5X","10X","20X")) 

outdir=args[4]
prefix=args[5]

N50=ggplot(f,aes(x=Assembly,fill=Assembly,y=N50.good.contigs/1000))+geom_bar(stat="identity")+facet_grid(~f$Illumina.coverage)+labs(y="N50 (kb)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes"))

max_contig=ggplot(f,aes(x=Assembly,fill=Assembly,y=Max.good.contig.length/1000))+geom_bar(stat="identity")+facet_grid(~f$Illumina.coverage)+labs(y="Largest contig (kb)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes")) 

misassembled_contigs=ggplot(f,aes(x=Assembly,fill=Assembly,y=Misassembled.length/1000))+geom_bar(stat="identity")+facet_grid(~f$Illumina.coverage)+labs(y="Misassembled contigs (kb)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes")) 

misassembled_contigs_percent=ggplot(f,aes(x=Assembly,fill=Assembly,y=Misassembled.length/Total.length*100))+geom_bar(stat="identity")+facet_grid(~f$Illumina.coverage)+labs(y="Misassembled contigs (%)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes"))+ylim(0,100) 

contigsLength=ggplot(f_contigs,aes(x=Assembly,fill=Contig,y=Length/1000000))+geom_bar(stat="identity")+scale_fill_manual(values=c("lightgreen","limegreen","red","purple","blue"))+labs(y="Length (Mb)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+facet_grid(~f_contigs$Illumina.coverage)+scale_x_discrete(labels=c("1","2","3"))   
contigsNumber=ggplot(f_contigs,aes(x=Assembly,fill=Contig,y=Number))+geom_bar(stat="identity")+scale_fill_manual(values=c("lightgreen","limegreen","red","purple","blue"))+labs(t="Number of contigs")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+facet_grid(~f_contigs$Illumina.coverage)+scale_x_discrete(labels=c("1","2","3"))  

refCov=ggplot(f_plasmids,aes(x=Assembly,y=Aligned_length/Length*100,fill=Assembly))+geom_boxplot()+facet_grid(~Illumina.coverage)+labs(y="Reference coverage(%)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes")) 

f_complet=subset(f_plasmids,f_plasmids$Status=="complete") 

completePlasmids=ggplot(f_complet,aes(x=Assembly,fill=Assembly))+geom_bar()+facet_grid(~Illumina.coverage)+geom_hline(yintercept=1828)+labs(y="Number of complete plasmids")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes"))
grid.text("Total number\n of plasmids", x = unit(0.81, "npc"), y = unit(0.915, "npc"),hjust=0,gp=gpar(fontsize=14))

completePlasmidsPercentLength=ggplot(f,aes(x=Assembly,fill=Assembly,y=X.Plasmids.complete..length.))+geom_bar(stat="identity")+facet_grid(~f$Illumina.coverage)+labs(y="Complete plasmids (%Length)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes"))+ylim(0,100) 

#Abundance 
#Separate into 4 equal parts 

first=subset(f_plasmids,f_plasmids$Abundance<unname(quantile(f_plasmids$Abundance)["25%"]))
second=subset(f_plasmids,f_plasmids$Abundance>=unname(quantile(f_plasmids$Abundance)["25%"]))
second=subset(second,second$Abundance<unname(quantile(f_plasmids$Abundance)["50%"]))
third=subset(f_plasmids,f_plasmids$Abundance>=unname(quantile(f_plasmids$Abundance)["50%"]))
third=subset(third,third$Abundance<unname(quantile(f_plasmids$Abundance)["75%"]))
fourth=subset(f_plasmids,f_plasmids$Abundance>=unname(quantile(f_plasmids$Abundance)["75%"]))

first$Cat="<0.051" 
second$Cat="0.051-0.053" 
third$Cat="0.053-0.057" 
fourth$Cat=">=0.057"

f_plasmids=rbind(first,second,third,fourth) 
f_plasmids$Cat=factor(f_plasmids$Cat,levels=c(">=0.057","0.053-0.057","0.051-0.053","<0.051"))

abundance=ggplot(f_plasmids,aes(x=Cat,y=Aligned_length/Length*100))+geom_boxplot()+labs(y="Reference coverage(%)",x="Abundance")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14))+coord_flip()+facet_grid(Illumina.coverage~.)

abundanceDetailed=ggplot(f_plasmids,aes(x=Cat,y=Aligned_length/Length*100,fill=Assembly))+geom_boxplot()+labs(y="Reference coverage(%)",x="Abundance")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+coord_flip()+facet_grid(Illumina.coverage~.)+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes"))

#Length

first=subset(f_plasmids,f_plasmids$Length<13000)
second=subset(f_plasmids,f_plasmids$Length>=13000)
second=subset(second,second$Length<55000)
third=subset(f_plasmids,f_plasmids$Length>=55000)
third=subset(third,third$Length<157000)
fourth=subset(f_plasmids,f_plasmids$Length>=157000)

first$CatLength="<13kb (n=466)" 
second$CatLength="13-55kb (n=451)" 
third$CatLength="55-157kb (n=453)" 
fourth$CatLength=">=157kb (n=458)"

f_plasmids=rbind(first,second,third,fourth) 

f_plasmids$CatLength=factor(f_plasmids$CatLength,levels=c(">=157kb (n=458)","55-157kb (n=453)","13-55kb (n=451)","<13kb (n=466)"))

length=ggplot(f_plasmids,aes(x=CatLength,y=Aligned_length/Length*100))+geom_boxplot()+labs(y="Coverage(%)",x="Length")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14))+coord_flip()+facet_grid(Illumina.coverage~.) 

lengthDetailed=ggplot(f_plasmids,aes(x=CatLength,y=Aligned_length/Length*100,fill=Assembly))+geom_boxplot()+labs(y="Coverage(%)",x="Length")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+coord_flip()+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler"))+facet_grid(Illumina.coverage~.) 

principalStats=ggarrange(N50,max_contig,misassembled_contigs,completePlasmids,ncol=2,nrow=2,common.legend=TRUE,legend="bottom") 


outN50=outputName(outdir,prefix,".N50.svg") 
outMax=outputName(outdir,prefix,".MaxContig.svg") 
outMis=outputName(outdir,prefix,".MisassembledContigs.svg") 
outMisPercent=outputName(outdir,prefix,".MisassembledContigsPercent.svg") 
outContigLength=outputName(outdir,prefix,".AllContigsLength.svg") 
outContigNumber=outputName(outdir,prefix,".AllContigsNumber.svg") 
outRefCov=outputName(outdir,prefix,".RefCov.svg")
outCompPlas=outputName(outdir,prefix,".completePlasmids.svg") 
outCompPlasPerc=outputName(outdir,prefix,".completePlasmidsPercent.svg") 
outAbundanceDetailed=outputName(outdir,prefix,".AbundanceDetailed.svg") 
outAbundance=outputName(outdir,prefix,".Abundance.svg")
outLength=outputName(outdir,prefix,".Length.svg")
outLengthDetailed=outputName(outdir,prefix,".LengthDetailed.svg")

outN50_pdf=outputName(outdir,prefix,".N50.pdf") 
outMax_pdf=outputName(outdir,prefix,".MaxContig.pdf") 
outMis_pdf=outputName(outdir,prefix,".MisassembledContigs.pdf") 
outMisPercent_pdf=outputName(outdir,prefix,".MisassembledContigsPercent.pdf") 
outContigLength_pdf=outputName(outdir,prefix,".AllContigsLength.pdf") 
outContigNumber_pdf=outputName(outdir,prefix,".AllContigsNumber.pdf") 
outRefCov_pdf=outputName(outdir,prefix,".RefCov.pdf")
outCompPlas_pdf=outputName(outdir,prefix,".completePlasmids.pdf") 
outCompPlasPerc_pdf=outputName(outdir,prefix,".completePlasmidsPercent.pdf") 
outAbundanceDetailed_pdf=outputName(outdir,prefix,".AbundanceDetailed.pdf") 
outAbundance_pdf=outputName(outdir,prefix,".Abundance.pdf")
outLength_pdf=outputName(outdir,prefix,".Length.pdf")
outLengthDetailed_pdf=outputName(outdir,prefix,".LengthDetailed.pdf")
outPrincipalStat=outputName(outdir,prefix,".principalStats.pdf")

ggsave(file=outN50, plot=N50, width=10, height=8)
ggsave(file=outMax,plot=max_contig,width=10,height=8) 
ggsave(file=outMis,plot=misassembled_contigs,width=10,height=8) 
ggsave(file=outMisPercent,plot=misassembled_contigs_percent,width=10,height=8) 
ggsave(file=outContigLength,plot=contigsLength,width=10,height=8) 
ggsave(file=outContigNumber,plot=contigsNumber,width=10,height=8) 
ggsave(file=outRefCov,plot=refCov,width=10,height=8) 
ggsave(file=outCompPlas,plot=completePlasmids,width=10,height=8) 
ggsave(file=outCompPlasPerc,plot=completePlasmidsPercentLength,width=10,height=8)
ggsave(file=outAbundance,plot=abundance,width=10,height=8) 
ggsave(file=outAbundanceDetailed,plot=abundanceDetailed,width=10,height=8) 
ggsave(file=outLength,plot=length,width=10,height=8) 
ggsave(file=outLengthDetailed,plot=lengthDetailed,width=10,height=8) 

pdf(outN50_pdf) 
N50
dev.off() 
pdf(outMax_pdf) 
max_contig
dev.off() 
pdf(outMis_pdf) 
misassembled_contigs
dev.off() 
pdf(outMisPercent_pdf) 
misassembled_contigs_percent
dev.off() 
pdf(outContigLength_pdf) 
contigsLength
dev.off() 
pdf(outContigNumber_pdf) 
contigsNumber
dev.off() 
pdf(outRefCov_pdf) 
refCov
dev.off() 
pdf(outCompPlas_pdf) 
completePlasmids
dev.off()
pdf(outCompPlasPerc_pdf) 
completePlasmidsPercentLength
dev.off()
pdf(outAbundance_pdf) 
abundance
dev.off()
pdf(outAbundanceDetailed_pdf) 
abundanceDetailed
dev.off()
pdf(outLength_pdf) 
length
dev.off()
pdf(outLengthDetailed_pdf) 
lengthDetailed
dev.off()
pdf(outPrincipalStat,onefile=TRUE)
principalStats
dev.off() 



