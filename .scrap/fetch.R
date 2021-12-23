case_death_url<-'https://arcgis.com/sharing/rest/content/items/e16df1fa98c2452783ec10b0aea4b341/data'
vax_url<-'https://arcgis.com/sharing/rest/content/items/b860f2797f7f4da789cb6fccf6bd5bc7/data'

#pseudo-TERYT of a whole country
t0<-"t0000"

#pseudo-TERYT of unknown
t0n<-"t00"

download_package<-function(url){
 #Download and unzip
 tempfile()->p
 download.file(url,p)
 sprintf("%s/%s",tempdir(),paste(sample(letters,10),collapse=''))->d
 unzip(p,exdir=d)
 d
}

rb<-function(x) do.call(rbind,x)

import_cd<-function(d){
 rb(lapply(list.files(d,patt='csv$',full.names=TRUE),function(fn){ 
  read.csv2(fn)->x

  #Extract date from the file name
  x$date<-gsub('^.*(\\d{8})\\d{6}.*$','\\1',basename(fn))

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
 }))
}

import_vax<-function(d){
 rb(lapply(list.files(d,patt='pow_szczepienia.csv$',full.names=TRUE),function(fn){ 
  read.csv2(fn)->x

  #Extract date from the file name
  x$date<-gsub('^(\\d{8}).*$','\\1',basename(fn))

  #Extract useful and consistently reported data only
  if(!"dawka_przypominajaca_dziennie"%in%names(x)) x$dawka_przypominajaca_dziennie<-0
  x[,c("liczba_szczepien_dziennie","dawka_2_dziennie","dawka_przypominajaca_dziennie","teryt","date")]->x
  names(x)<-c("vax_first","vax_full","vax_booster","teryt","date")

  stopifnot(sum(x$teryt==t0n)<=1)
  x[x$teryt!=t0,]->x
  x$teryt[x$teryt==t0n]<-NA

  x[order(x$teryt),]->x
  x[(x$vax_first>0) | (x$vax_full>0) | (x$vax_booster>0),]->x

  x
 }))
}

drop_dirs<-function(Q,pfx){
 #Drop each day in a Y/M/D directory structure
 for(x in split(Q,Q$date)){
  d<-head(x$date,1)
  f<-sprintf("%s/%s/%s%s.tsv",
          substr(d,1,4),substr(d,5,6),pfx,d)
  dir.create(dirname(f),showWarnings=FALSE,recursive=TRUE)
  write.table(x,row.names=FALSE,sep='\t',f)
 }
}

drop_file<-function(Q,fn){
 Q[order(Q$teryt,Q$date),]->Q
 write.table(Q,row.names=FALSE,sep='\t',fn)
}


if(!interactive()){
 #Cases download & convert
 import_cd(download_package(case_death_url))->Qa

 #Render
 drop_dirs(Qa,'covid_govpl_')
 drop_file(Qa,'covid_govpl.tsv')
 
 #Vax download & convert
 import_vax(download_package(vax_url))->Qv

 #Render
 drop_dirs(Qv,'covid_vax_')
 drop_file(Qv,'covid_vax.tsv')

 #Drop a per-day summary
 data.frame(
  new_cases=tapply(Qa$new_cases,Qa$date,sum),
  deaths=tapply(Qa$deaths,Qa$date,sum),
  date=tapply(Qa$date,Qa$date,head,1)
 )->Qd
 write.table(Qd,row.names=FALSE,sep='\t','covid_govpl_daily.tsv')
}

