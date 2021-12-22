case_death_url<-'https://arcgis.com/sharing/rest/content/items/e16df1fa98c2452783ec10b0aea4b341/data'
vax_url<-'https://arcgis.com/sharing/rest/content/items/b860f2797f7f4da789cb6fccf6bd5bc7/data'

#pseudo-TERYT of a whole country
t0<-"t0000"

download_package<-function(url){
 #Download and unzip
 tempfile()->p
 download.file(url,p)
 tempdir()->d
 unzip(p,exdir=d)
 d
}

import_cd<-function(d){
 lapply(list.files(d,patt='csv$',full.names=TRUE),function(fn){ 
  read.csv2(fn)->x

  #Extract date from the file name
  x$date<-gsub('^.*(\\d{8})\\d{6}.*$','\\1',fn)

  #Extract useful and consistently reported data only
  x[,c("liczba_przypadkow","zgony","teryt","date")]->x
  names(x)<-c("new_cases","deaths","teryt","date")

  x$new_cases[is.na(x$new_cases)]<-0
  #Deaths number is malformed in some files
  x$deaths<-as.numeric(x$deaths)
  x$deaths[is.na(x$deaths)]<-0

  stopifnot(sum(x$teryt==t0)<=1)

  #Convert whole-country total to a number with unknown location
  x$deaths[x$teryt==t0]<-x$deaths[x$teryt==t0]-sum(x$deaths[x$teryt!=t0])
  x$new_cases[x$teryt==t0]<-x$new_cases[x$teryt==t0]-sum(x$new_cases[x$teryt!=t0])
  x$teryt[x$teryt==t0]<-NA

  x[order(x$teryt),]->x
  x[(x$new_cases>0) | (x$deaths>0),]->x

  x
 })
}

if(!interactive()){
 #Download & convert
 import_cd(download_package(case_death_url))->Q
 
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

 #Drop a per-day summary
 data.frame(
  new_cases=tapply(Qa$new_cases,Qa$date,sum),
  deaths=tapply(Qa$deaths,Qa$date,sum),
  date=tapply(Qa$date,Qa$date,head,1)
 )->Qd
 write.table(Qd,row.names=FALSE,sep='\t','covid_govpl_daily.tsv')
}

