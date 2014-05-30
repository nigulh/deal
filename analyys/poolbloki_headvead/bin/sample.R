library(data.table)
df = data.table(read.csv("sample.data", header=T, sep=" "))
print("Lehed sorteerituna järjekorras")
df[order(noPar),]
print("Mitetsooni lehed, kus tuleb masti pakkuda")
df[Vul=="--"][order(noPar),]
df[Vul=="--"][order(noPar)][,list(S,H,D,C,avg,ParPos,ParNeg,noPar)]
print("Tsoonsusest soltuvus!")
df[,list(avg=mean(avg),noPar=mean(noPar),ParPos=mean(ParPos),ParNeg=mean(ParNeg)),by=Vul]
print("Mastist soltuvus!")
df[,list(avg=mean(avg),noPar=mean(noPar),ParPos=mean(ParPos),ParNeg=mean(ParNeg)),by=Bid]

