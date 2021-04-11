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

for(x in Q)
 write.table(x,row.names=FALSE,sep='\t',sprintf('covid_govpl_%s.tsv',head(x$date,1)))
 

