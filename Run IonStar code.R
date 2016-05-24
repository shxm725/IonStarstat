rawfile <- "Raw_input_IonStar.csv"
condfile <- "Groups.txt"
raw <- read.csv(rawfile)
cond <- read.table(condfile, header=TRUE)
condition <- cond[match(colnames(raw)[-c(1:3)], cond[,1]),2]
pdata <- newProDataSet(proData=raw, condition=condition)
ndata <- pnormalize(pdata, summarize=TRUE, method="TIC")
cdata<-OutlierPeptideRM(ndata,condition,variance=0.7,critM1=1/3,critM2=1/4,ratio=TRUE)
cdata<-SharedPeptideRM(cdata)
quan <- ProteinQuan(eset=ndata, method="sum")
#pres <- ProteinTest(eset=ndata, condA="A", condB="B")
#quan <- ProteinQuan(eset=ndata, method="fit")


