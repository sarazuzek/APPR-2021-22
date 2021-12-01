# Analiza podatkov s programom R - 2021/22

Vzorčni repozitorij za projekt pri predmetu APPR v študijskem letu 2021/22. 

## Analiza smrti v Sloveniji

V projektu bom analizirala smrti v Sloveniji med leti 2010-2020. 
Primerjala bom število umrlih po spolu v posameznih občinah in regijah, pri regijah bom analizirali tudi najpogostejše vzroke za smrt glede na starostne skupine in povprečno starost umrlega.
Zanimalo me bo tudi ali je več samomorov med ženskami ali moškimi.
Primerjala bom umrle po starostnih skupinah glede na zakonski stan in izobrazbo, pogledala pa bom tudi ali je več smrti v zimskem letnem času.

### Podatki
Svoje podatke bom črpala s strani [SiStat](https://pxweb.stat.si/SiStat/sl) v obliki CSV datotek ter v HTML obliki. Shranjeni so v mapi [podatki](https://github.com/sarazuzek/APPR-2021-22/tree/main/podatki).

### Tabele
Tabela 1: Umrli po dnevu smrti
* leto (integer)
* mesec (integer)
* dan (integer)
* letni čas (character)
* število umrlih (integer)

Tabela 2: Umrli/umrli dojenčki na 1000 prebivalcev/živorojenih in povprečna starost umrlega, statistične regije
* leto (integer)
* regija (character)
* spol (factor)
* povprečna starost umrlega (double)
* umrli na 1000 prebivalcev (double)
* umrli dojenčki na 1000 živorojenih (double)

Tabela 3: Število umrlih po občinah
* občina (character)
* leto (integer)
* spol (factor)
* število umrlih (integer)

Tabela 4: Umrli po starostnih skupinah glede na zakonski stan in izobrazbo
* leto (integer)
* starostna skupina (factor)
* spol (factor)
* zakonski stan (character)
* izobrazba (character)

Tabela 5: Nezgode in samomori
* leto (integer)
* starostna skupina (factor)
* spol (factor)
* nezgode - transport (integer)
* padci (integer)
* druge nezgode (integer)
* samomori (integer)

Tabela 6: Najpogostejši vzrok smrti 
* leto (integer)
* spol (factor)
* regija (character)
* infekcijske in parazitske bolezni (character)
* neoplazme (character)
* bolezni obtočil (character)
* bolezni dihal (character)
* poškodbe, zastrupitve in druge posledice zunanjih vzrokov (character)

## Program

Glavni program in poročilo se nahajata v datoteki `projekt.Rmd`.
Ko ga prevedemo, se izvedejo programi, ki ustrezajo drugi, tretji in četrti fazi projekta:

* obdelava, uvoz in čiščenje podatkov: `uvoz/uvoz.r`
* analiza in vizualizacija podatkov: `vizualizacija/vizualizacija.r`
* napredna analiza podatkov: `analiza/analiza.r`

Vnaprej pripravljene funkcije se nahajajo v datotekah v mapi `lib/`.
Potrebne knjižnice so v datoteki `lib/libraries.r`
Podatkovni viri so v mapi `podatki/`.
Zemljevidi v obliki SHP, ki jih program pobere,
se shranijo v mapo `../zemljevidi/` (torej izven mape projekta).
