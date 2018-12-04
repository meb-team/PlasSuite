library(Nonpareil) 

args = commandArgs(trailingOnly=TRUE) 

if (length(args)!=2) {
  stop("usage : RScript --vanilla graphs.R <input.npo> <output>", call.=FALSE)
}

npo=args[1]
out=args[2]

pdf(out,width=10,height=7)
Nonpareil.curve(npo)
dev.off() 
