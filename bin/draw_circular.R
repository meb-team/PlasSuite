library(circlize) 

draw <- function(x){
	contig=read.table(x,header=TRUE,sep="\t")
	first=contig[1,]
	circos.initialize(c(first$name),xlim=c(0,first$end))
	title(paste(first$name,"length=",first$end)) 
	circos.track(c(first$name),ylim=c(0,1),track.height=0.05,bg.col="black")	
	cds=contig[2:nrow(contig),]
	cds$col=as.character(cds$col) 
	lapply(1:nrow(cds),function(x)if(cds[x,]$strand==1){circos.arrow(x1=cds[x,]$start,x2=cds[x,]$end,border=cds[x,]$col,width=2.5)}else{circos.arrow(x1=cds[x,]$start,x2=cds[x,]$end,border=cds[x,]$col,width=2.5,arrow.position="start")})
	lapply(1:nrow(cds),function(x) circos.text(x=cds[x,]$start+((cds[x,]$end-cds[x,]$start)/2),labels=cds[x,]$name,y=0.5,cex=0.5,niceFacing=TRUE))
}	

args = commandArgs(trailingOnly=TRUE) 

if (length(args)!=2) {
	stop("usage : RScript --vanilla drawContig.R <contig list> <output>", call.=FALSE)
}

f=read.table(args[1]) 
circos.par(start.degree=90) 
pdf(args[2])

lapply(f$V1,function(x)draw(paste(x,"genoplot",sep=".")))

dev.off() 
