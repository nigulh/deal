library(data.table)
args <- commandArgs(trailingOnly = TRUE)
print(args)
datafilename <- if (length(args) >= 1) args[1] else "stdin"
rm(args)
print(sprintf("datafile: %s", datafilename));

df = data.table(read.csv(datafilename, header=T, sep=" "))
len <- function(a) {return(nchar(lapply(a, as.character)));} # convert levels to string
print("Mitetsooni lehed, kus tuleb masti pakkuda")
df[Vul=="--"][order(noPar),]
df[Vul=="--"][order(noPar)][,list(S,H,D,C,avg,ParPos,ParNeg,noPar,Cnt)]
print("Tsoonsusest soltuvus!")
df[,list(avg=mean(avg),noPar=mean(noPar),ParPos=mean(ParPos),ParNeg=mean(ParNeg), sum=sum(Cnt)),by=list(Vul,len(Combo))][order(noPar)]
print("Mastist soltuvus!")
df[,list(avg=mean(avg),noPar=mean(noPar),ParPos=mean(ParPos),ParNeg=mean(ParNeg), sum=sum(Cnt)),by=list(Bid,len(Combo))][order(Bid,noPar)]
print("Combost soltuvus!")
df[,list(avg=mean(avg),noPar=mean(noPar),ParPos=mean(ParPos),ParNeg=mean(ParNeg), sum=sum(Cnt)),by=Combo][order(noPar)]
print("OtherCombost soltuvus!")
df[,list(avg=mean(avg),noPar=mean(noPar),ParPos=mean(ParPos),ParNeg=mean(ParNeg), sum=sum(Cnt)),by=OtherCombo][order(noPar)]

