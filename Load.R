#setwd("C:/Users/christina/Documents/R/Ionstar R Package")
###########File name of SIEVE file###################################
#db<-"140309_20runs.sdb"
###########File name of Spectrum report##############################
#xls<-"Spectrum Report for 20runs_experimental wide.xls"
library(RSQLite)
drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=db)
sql <- "select frames.frameid,(frames.timestart+frames.timestop)/2 as Time,(frames.mzstart+frames.mzstop)/2 as MZ, ms2scans.ms2scan, ms2scans.RawFileID, FrameAttrib_1.* from Frames 
INNER JOIN MS2Scans on MS2Scans.FrameID=Frames.frameid 
INNER JOIN FrameAttrib_1 ON FrameAttrib_1.FrameID=Frames.FrameID
order by Frames.Frameid"
frame <- dbGetQuery(con, sql)
RawFiles <- dbGetQuery(con, "select * from RawFiles")
dbDisconnect(con)
raw <- RawFiles[match(frame[,"ms2scans.RawFileID"], RawFiles[,"RFID"]), "RawFile"]
raw <- sub(".raw", "", raw)
frame <- cbind(frame, RAWFILE=raw)
startRow <- grep("Experiment name", readLines(xls, n=200)) - 1
Spectrum <- read.csv(xls, sep="\t", skip=startRow)
frame[,"RAWFILE"]<-toupper(sub(".RAW","",frame[,"RAWFILE"])) #DELETE .RAW
nframe <- toupper(paste(frame[,"RAWFILE"], frame[,"ms2scans.ms2scan"], sep="_"))
nSepc <- toupper(sub("-\\d*-\\d*-\\d*", "", Spectrum[,"Spectrum.name"]))
nSepc <- toupper(sub("-\\d*-\\d*", "", Spectrum[,"Spectrum.name"]))
idx <- match(nSepc, nframe)
paste(sum(is.na(idx)),"spectrum don't have matched frame.")
FS <- cbind(Spectrum[!is.na(idx),], frame[na.omit(idx),])
FS[,"Protein.accession.numbers"]<- toupper(sub("\\,.*", "", FS[,"Protein.accession.numbers"]))
FS[,"Protein.accession.numbers"]<- sub("\\,.*", "", FS[,"Protein.accession.numbers"])
FS[,"Protein.accession.numbers"]<- toupper(sub("SP\\|", "", FS[,"Protein.accession.numbers"]))
FS[,"Protein.accession.numbers"]<- toupper(sub("\\|", ":", FS[,"Protein.accession.numbers"]))
###############################################
#write.csv(FS, "Merged_spectra_SIEVE.csv")
