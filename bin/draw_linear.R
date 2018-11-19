library(genoPlotR) 

draw <- function(x){
	path=paste(x,"genoplot",sep=".")
	dnasegs=lapply(path,function(x) read_dna_seg_from_tab(x,header=TRUE))
	contigs=lapply(dnasegs,function(x)x[1,])
	features=lapply(dnasegs,function(x)x[2:nrow(x),])
	annot1=annotation(x1=0,text="")
	annot2=lapply(features,function(x)annotation(x1=middle(x),text=x$name,col=x$col,rot=75))
	annot=lapply(seq_along(dnasegs),function(x)if (nrow(dnasegs[[x]])==1){annot1[[x]]}else{rbind(annot1[[x]],annot2[[x]])})
	if (length(dnasegs)==1){
		plot_gene_map(list(dnasegs[[1]]),arrow_head_len=1000,annotations=annot,annotation_cex=0.5,main=x,scale=FALSE,scale_cex=0.5) 
	} else {
		plot_gene_map(dnasegs,arrow_head_len=40,annotations=annot,annotation_cex=0.5) 
	}	
	
	
}	

args = commandArgs(trailingOnly=TRUE) 

if (length(args)!=2) {
  stop("usage : RScript --vanilla drawContig.R <contig list> <output>", call.=FALSE)
}

f=read.table(args[1]) 
pdf(args[2])
lapply(f$V1,function(x)draw(x))
dev.off() 
