library(httr)
library(xml2)

url0<-'https://www.gov.pl%s'

n<-sprintf(url0,'/web/koronawirus/pliki-archiwalne-powiaty')
message("Downloading index from ",n)

GET(n)->s
xml_attr(A<-xml_find_all(content(s),'//a[@class="file-download"]'),'href')->W

xml_text(xml_find_all(A,'.//span[@class="extension"]'))->f
gsub('\u200b','',f)->f

dp<-list()
dp$a<-function(x){
 gsub(
  '^(..)_(..)_(..)_?powiaty(_GIS)?.csv$',
  '20\\3\\2\\1',
 x)->xn
 xn[xn==x]<-NA
 xn
}
dp$b<-function(x){
 gsub(
  '^(..)_(..)_20(..)_?powiaty(_GIS)?.csv$',
  '20\\3\\2\\1',
 x)->xn
 xn[xn==x]<-NA
 xn
}
dp$c<-function(x){
 gsub(
  '^([0123456789]{2})([0123456789]{2})([0123456789]{4})_powiaty(\\(2\\)|_GIS)?.csv$',
  '\\3\\2\\1',
 x)->xn
 xn[xn==x]<-NA
 xn
}
dp$d<-function(x){
 gsub(
  '^([0123456789]{4})([0123456789]{2})([0123456789]{2})([0123456789]{6})_rap.*csv$',
  '\\1\\2\\3',
 x)->xn
 xn[xn==x]<-NA
 xn
}

do.call(cbind,lapply(dp,function(p) p(f)))->K
apply(K,1,function(x) na.omit(x)[1])->fp


lapply(W,function(w){
 n<-sprintf(url0,w)
 message("Downloading ",n)
 Sys.sleep(1)
 GET(n)->z
 read.csv2(textConnection(content(z,as='text',encoding="cp1250")))
})->Q

lapply(1:length(Q),function(e){
 Q[[e]]->x
 x$date<-fp[e]
 x
})->Q

keys<-list(
 new_cases=c("liczba_przypadkow","Liczba.przypadków","Liczba"),
 deaths=c("zgony","Zgony","Wszystkie.przypadki.śmiertelne"),
 teryt=c("id","teryt","TERYT"),
 date="date"
)

unify<-function(x){
 ans<-list()
 for(key in names(keys)){
  k<-keys[[key]]
  k[k%in%names(x)]->k
  ans[[key]]<-x[[k]]
 }
 as.data.frame(ans)
}

Q<-lapply(Q,function(raw){
 x<-try(unify(raw))
 if(inherits(x,"try-error")){
  return(NULL)
 }
 x$new_cases[is.na(x$new_cases)]<-0
 x$deaths[is.na(x$deaths)]<-0
 x[x$teryt!="t0000",]->x
 x[order(x$teryt),]->x
 x[(x$new_cases>0) | (x$deaths>0),]->x
 x
})

Q[!sapply(Q,is.null)]->Q

for(x in Q)
 write.table(x,row.names=FALSE,sprintf('covid_govpl_%s.tsv',head(x$date,1)))

