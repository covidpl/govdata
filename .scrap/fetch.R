if(!file.exists('danehistorycznepowiaty.zip')){
 stop("Unfortunately, automatic download from gov.pl is impossible
 since ArcGIS system is used. Fetch the danehistorycznepowiaty.zip 
 file by yourself and re-reun")
}

#Unzip
tempdir()->d
unzip('danehistorycznepowiaty.zip',exdir=d)


lapply(list.files(d,patt='csv$',full.names=TRUE),function(fn){ 
	read.csv2(fn)->x

 #Extract date from the file name
	x$date<-gsub('^.*(\\d{8})\\d{6}.*$','\\1',fn)

 #Extract useful and consistently reported data only
	x[,c("liczba_przypadkow","zgony","teryt","date")]->x
	names(x)<-c("new_cases","deaths","teryt","date")

 x[x$teryt!="t0000",]->x
 x$new_cases[is.na(x$new_cases)]<-0
 #Deaths number is malformed in some files
 x$deaths<-as.numeric(x$deaths)
 x$deaths[is.na(x$deaths)]<-0
 x[order(x$teryt),]->x
 x[(x$new_cases>0) | (x$deaths>0),]->x
	x
})->Q

if(!interactive()){
 #Drop each day in a Y/M/D directory structure
 for(x in Q){
  d<-head(x$date,1)
  f<-sprintf("%s/%s/covid_govpl_%s.tsv",
          substr(d,1,4),substr(d,5,6),d)
  dir.create(dirname(f),showWarnings=FALSE,recursive=TRUE)
  write.table(x,row.names=FALSE,sep='\t',f)
 }
  
 #Drop everything in a single large file
 do.call(rbind,Q)->Qa
 Qa[order(Qa$teryt,Qa$date),]->Qa
 write.table(Qa,row.names=FALSE,sep='\t','covid_govpl.tsv')
}
