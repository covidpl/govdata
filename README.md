# COVID-19 data scrapped from the gov.pl site

This repository holds the data about new cases of COVID-19 and related deaths published on the gov.pl site, distributed over days and [powiats](https://en.wikipedia.org/wiki/Powiat), LAU/NUTS-4 administrative units of Poland, as well as COVID-19 vaccination data.

The case/death part is available in a single tab-separated text file under this link [`https://raw.githubusercontent.com/covidpl/govdata/master/covid_govpl.tsv`](https://raw.githubusercontent.com/covidpl/govdata/master/covid_govpl.tsv); there is also a file-per-day version in a year/month/day hierarchy.

Each file has 4 columns:
1. `new_cases`, the number of new cased at a particular date in a particular powiat,
2. `deaths`, the number of deaths at a particular date in a particular powiat,
3. `teryt`, the [TERYT code](https://eteryt.stat.gov.pl/eTeryt/rejestr_teryt/aktualnosci/aktualnosci.aspx) identifying the said powiat, prefixed with `t` character to prevent accidental conversion into a number,
4. `date`, the said date, in YYYYMMDD format.

The vaccination part is available in a single tab-separated text file under this link [`https://raw.githubusercontent.com/covidpl/govdata/master/covid_vax.tsv`](https://raw.githubusercontent.com/covidpl/govdata/master/covid_vax.tsv); there is also a file-per-day version in a year/month/day hierarchy.

Each file has 4 columns:
1. `vax_first`, the number of first doses administered at a particular date in a particular powiat,
2. `vax_full`, the number of second doses administered at a particular date in a particular powiat,
3. `vax_booster`, the number of booster doses administered at a particular date in a particular powiat,
4. `teryt`, the [TERYT code](https://eteryt.stat.gov.pl/eTeryt/rejestr_teryt/aktualnosci/aktualnosci.aspx) identifying the said powiat, prefixed with `t` character to prevent accidental conversion into a number,
5. `date`, the said date, in YYYYMMDD format.

Some records are not localised, and they are assigned to a `NA` value in the `teryt` column.
Records with all counts equal zero are omitted.

The registry is manually updated on a semi-regular basis, using [the R script provided with the data](https://github.com/covidpl/govdata/blob/master/.scrap/fetch.R).

## Notes
- The data is unreliable, especially the new cases records, due to varying testing strategy. Weekends and holidays cause reporting delays and testing downtimes, which contribute to an evident weekly cycle and some spurious dents. Low-pass filtering is advised for somewhat more accurate picture.
- The data starts in a strange moment (24 XI 2020), which corresponds to a substantial change in reporting policy. For earlier data, you can find [this citizen-science project lead by Mr. Michał Rogalski](http://bit.ly/covid19-poland) useful.
- Vaccination data starts at 13 I 2021; doses administered before are not counted (this is a rather small number).
- There are more fields in the source data, which you somehow might found useful.
- Provided AS IS, without any guarantees. USE AT YOUR OWN RISK.


