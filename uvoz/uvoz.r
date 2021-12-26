# 2. faza: Uvoz podatkov

library(readr)
library(stringr)
library(dplyr)
library(tidyr)
library(tidyverse)


sl <- locale("sl", decimal_mark=",", grouping_mark=".")

################################# 1.tabela #################################
regije <- read_csv("podatki/regije.csv", na="-", skip = 1,
                   locale=locale(encoding="Windows-1250"), col_names =TRUE)

regije <- pivot_longer(regije,
                       cols = colnames(regije)[-c(1,2)],
                       names_to = "leto",
                       values_to = "umrli") #združimo več stolpcev v enega

colnames(regije)[1] <- 'spol'
colnames(regije)[2] <- 'regija'

regije <- regije %>%
  tidyr::extract(
    col = leto,
    into = c("leto", "kriterij"),
    regex = "^(\\d{4})\\s+(.*)$"
  )  #ločimo leto in kriterij


vektor_kriterija <- unique(regije$kriterij) %>% sort()

vrste_kriterija = data.frame(
  kriterij = vektor_kriterija,
  lepse = c(
    "povprecna.starost.umrlega",
    "umrli.dojencki.na.1000.zivorojenih",
    "umrli.na.1000.prebivalcev"
  )
)
  
regije <- regije %>% left_join(vrste_kriterija, by = c("kriterij"))

regije <- regije %>% select(spol, regija, leto, kriterij = lepse, umrli)


oznaka_spolov = tibble(
  spol = c(
    "Moški",
    "Ženske"
  ),
  oznaka = c(
    "M",
    "Z"
  )
)

regije <- regije %>% left_join(oznaka_spolov, by = c("spol"))

regije <- regije %>% select(spol = oznaka, regija, leto, kriterij, umrli)


oznaka_regij = tibble(
  regija = c(
    "SLOVENIJA",
    "Gorenjska",
    "Goriška",
    "Jugovzhodna Slovenija",
    "Koroška",
    "Obalno-kraška",
    "Osrednjeslovenska",
    "Podravska",
    "Pomurska",
    "Posavska",
    "Primorsko-notranjska",
    "Savinjska",
    "Zasavska"
  ),
  oznaka = c(
    "SLO", 
    "KR", 
    "NG", 
    "NM", 
    "SG", 
    "KP", 
    "LJ", 
    "MB", 
    "MS", 
    "KK", 
    "PO", 
    "CE", 
    "ZA"
  )
)

regije <- regije %>% left_join(oznaka_regij, by = c("regija"))

regije <- regije %>% select(spol, regija = oznaka, leto, kriterij, umrli)



################################# 2.tabela #################################
obcine <- read_csv("podatki/obcine.csv", na="-", skip = 1,
                   locale=locale(encoding="Windows-1250"), col_names =TRUE)

obcine <- pivot_longer(obcine,
                       cols = colnames(obcine)[-c(1)],
                       names_to = "leto",
                       values_to= "stevilo.umrlih"
                       )

colnames(obcine)[1] <- 'obcina'

obcine <- obcine %>%
  tidyr::extract(
    col = leto,
    into = c("leto", "umrli","spol"),
    regex = "^(\\d{4})\\s(\\D{5})\\s+(.*)$"
  ) 

obcine <- obcine %>% select(obcina, leto, spol, stevilo.umrlih)

obcine <- obcine %>% left_join(oznaka_spolov, by = c("spol"))

obcine <- obcine %>% select(obcina, leto, spol = oznaka, stevilo.umrlih)

#izbrisem NA vrstice
obcine <- obcine %>% dplyr::filter(!is.na(stevilo.umrlih))

#obcine <- sub('Ankaran/Ancarano', 'Ankaran', obcine)
# treba še spremeniti imena nekaterih občin



################################# 3.tabela #################################
#1.tabela
stan <- read_csv("podatki/zakonski_stan.csv", na="-", skip = 1,
                          locale=locale(encoding="Windows-1250"), col_names =TRUE)

stan <- pivot_longer(stan,
                     cols = colnames(stan)[-c(1,2,3)],
                     names_to = "stan",
                     values_to = "stevilo.umrlih")

colnames(stan)[1] <- "leto" 
colnames(stan)[2] <- "spol" 
colnames(stan)[3] <- "starostne.skupine" 

stan <- stan %>% left_join(oznaka_spolov, by = c("spol"))

stan <- stan %>% select(leto, spol = oznaka, starostne.skupine, stan, stevilo.umrlih)

vektor_skupin <- unique(stan$starostne.skupine) %>% sort()

oznaka_starostnih_skupin = tibble(
  starostne.skupine = vektor_skupin,
  lepse = c( "15-19", "20-24","25-29", "30-34", "35-39", "40-44", "45-49", "50-54",
             "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85+", "0-15")
  )

stan <- stan %>% left_join(oznaka_starostnih_skupin, by = c("starostne.skupine"))

stan <- stan %>% select(leto, spol, starostne.skupine = lepse, stan, stevilo.umrlih)

oznaka_stana = tibble(
  stan = c("Samski/a", "Poročen/a", "Vdovec/Vdova", "Razvezan/a"),
  lepse = c("samski/a", "porocen/a", "vdovec/vdova", "razvezan/a")
)

stan <- stan %>% left_join(oznaka_stana, by = c("stan"))

stan <- stan %>% select(leto, spol, starostne.skupine, stan = lepse, stevilo.umrlih)

#2.tabela
izobrazba <- read_csv("podatki/izobrazba.csv", na="-", skip = 1,
                      locale=locale(encoding="Windows-1250"), col_names =TRUE)

izobrazba <- pivot_longer(izobrazba,
                          cols = colnames(izobrazba)[-c(1,2,3)],
                          names_to = "izobrazba",
                          values_to = "stevilo.umrlih")

colnames(izobrazba)[1] <- "leto" 
colnames(izobrazba)[2] <- "spol" 
colnames(izobrazba)[3] <- "starostne.skupine" 

izobrazba <- izobrazba %>% left_join(oznaka_spolov, by = c("spol"))

izobrazba <- izobrazba %>% select(leto, spol = oznaka, starostne.skupine, izobrazba, stevilo.umrlih)

izobrazba <- izobrazba %>% left_join(oznaka_starostnih_skupin, by = c("starostne.skupine"))

izobrazba <- izobrazba %>% select(leto, spol, starostne.skupine = lepse, izobrazba, stevilo.umrlih)

oznaka_izobrazbe = tibble(
  izobrazba = c("Brez izobrazbe, nepopolna osnovnošolska",
                "Osnovnošolska",
                "Srednješolska",
                "Višješolska, visokošolska",
                "Neznano"),
  lepse = c("Brez",
            "OS",
            "SS",
            "VS",
            "Neznano")
)


izobrazba <- izobrazba %>% left_join(oznaka_izobrazbe, by = c("izobrazba"))

izobrazba <- izobrazba %>% select(leto, spol, starostne.skupine, izobrazba = lepse, stevilo.umrlih)

#1 + 2 tabela



################################# 4.tabela #################################
# nezgode_samomori = iz spletne strani


################################# 5.tabela #################################
vzrok_smrti <- read_csv("podatki/najpogostejsi_vzrok_smrti.csv", na="-", skip = 1,
         locale=locale(encoding="Windows-1250"), col_names =TRUE)


################################# 6.tabela #################################
svet_samomori <- read_csv("podatki/samomori_svet.csv", na="-",
         locale=locale(encoding="Windows-1250"), col_names =TRUE)

bdp <- read_csv("podatki/bdp.csv", na="-",
                locale=locale(encoding="Windows-1250"), col_names =TRUE)

 