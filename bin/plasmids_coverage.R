args = commandArgs(trailingOnly=TRUE) 

if (length(args)!=1) {
  stop("usage : RScript --vanilla graphs.R <plasmids stats>", call.=FALSE)
}

f=read.table(args[1],sep="\t") 

sum(f$V7)/sum(f$V6)*100
sum(f$V8)/sum(f$V6)*100

