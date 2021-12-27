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

colnames(regije)[1] <- "spol"
colnames(regije)[2] <- "regija"

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

colnames(obcine)[1] <- "obcina"

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

#uredimo imena občin, tistih ki imajo /
a = str_replace_all(obcine$obcina, "Ankaran/Ancarano", "Ankaran")
obcine$obcina = a

d = str_replace_all(obcine$obcina, "Dobrovnik/Dobronak","Dobrovnik")
obcine$obcina = d

h = str_replace_all(obcine$obcina, "Hodoš/Hodos", "Hodoš")
obcine$obcina = h

i = str_replace_all(obcine$obcina, "Izola/Isola", "Izola")
obcine$obcina = i

k = str_replace_all(obcine$obcina, "Koper/Capodistria", "Koper")
obcine$obcina = k

l = str_replace_all(obcine$obcina, "Lendava/Lendva", "Lendava")
obcine$obcina = l

p = str_replace_all(obcine$obcina, "Piran/Pirano", "Piran")
obcine$obcina = p



################################# 3.tabela #################################
#1.tabela
stan <- read_csv("podatki/zakonski_stan.csv", na="-", skip = 1,
                          locale=locale(encoding="Windows-1250"), col_names =TRUE)

stan <- pivot_longer(stan,
                     cols = colnames(stan)[-c(1,2,3)],
                     names_to = "stan",
                     values_to = "stevilo.umrlih.stan")

colnames(stan)[1] <- "leto" 
colnames(stan)[2] <- "spol" 
colnames(stan)[3] <- "starostne.skupine" 

stan <- stan %>% left_join(oznaka_spolov, by = c("spol"))
stan <- stan %>% select(leto, spol = oznaka, starostne.skupine, stan, stevilo.umrlih.stan)

vektor_skupin <- unique(stan$starostne.skupine) %>% sort()

oznaka_starostnih_skupin = tibble(
  starostne.skupine = vektor_skupin,
  lepse = c( "15-19", "20-24","25-29", "30-34", "35-39", "40-44", "45-49", "50-54",
             "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85+", "0-15")
  )

stan <- stan %>% left_join(oznaka_starostnih_skupin, by = c("starostne.skupine"))
stan <- stan %>% select(leto, spol, starostne.skupine = lepse, stan, stevilo.umrlih.stan)

oznaka_stana = tibble(
  stan = c("Samski/a", "Poročen/a", "Vdovec/Vdova", "Razvezan/a"),
  lepse = c("samski/a", "porocen/a", "vdovec/vdova", "razvezan/a")
)

stan <- stan %>% left_join(oznaka_stana, by = c("stan"))
stan <- stan %>% select(leto, spol, starostne.skupine, stan = lepse, stevilo.umrlih.stan)

#2.tabela
izobrazba <- read_csv("podatki/izobrazba.csv", na="-", skip = 1,
                      locale=locale(encoding="Windows-1250"), col_names =TRUE)

izobrazba <- pivot_longer(izobrazba,
                          cols = colnames(izobrazba)[-c(1,2,3)],
                          names_to = "izobrazba",
                          values_to = "stevilo.umrlih.izobrazba")

colnames(izobrazba)[1] <- "leto" 
colnames(izobrazba)[2] <- "spol" 
colnames(izobrazba)[3] <- "starostne.skupine" 

izobrazba <- izobrazba %>% left_join(oznaka_spolov, by = c("spol"))
izobrazba <- izobrazba %>% select(leto, spol = oznaka, starostne.skupine, izobrazba, stevilo.umrlih.izobrazba)

izobrazba <- izobrazba %>% left_join(oznaka_starostnih_skupin, by = c("starostne.skupine"))
izobrazba <- izobrazba %>% select(leto, spol, starostne.skupine = lepse, izobrazba, stevilo.umrlih.izobrazba)

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
izobrazba <- izobrazba %>% select(leto, spol, starostne.skupine, izobrazba = lepse, stevilo.umrlih.izobrazba)

#1 + 2 tabela
skupaj <- merge(izobrazba, stan, all = TRUE)

skupaj$izobrazba <- as.character(skupaj$izobrazba)
skupaj$izobrazba[is.na(skupaj$izobrazba)] <- "ni.podatka"

skupaj$stevilo.umrlih.izobrazba <- as.character(skupaj$stevilo.umrlih.izobrazba)
skupaj$stevilo.umrlih.izobrazba[is.na(skupaj$stevilo.umrlih.izobrazba)] <- "ni.podatka"



################################# 4.tabela #################################
# nezgode_samomori = iz spletne strani


################################# 5.tabela #################################
vzrok_smrti <- read_csv("podatki/najpogostejsi_vzrok_smrti.csv", na="-",
         locale=locale(encoding="Windows-1250"), col_names =TRUE)

vzrok_smrti <- pivot_longer(vzrok_smrti,
                            cols = colnames(vzrok_smrti)[-c(1,2)],
                            names_to = "leto",
                            values_to = "stevilo.umrlih")

colnames(vzrok_smrti)[1] = "spol"
colnames(vzrok_smrti)[2] = "regija"

vzrok_smrti <- vzrok_smrti %>%
  tidyr::extract(
    col = leto,
    into = c("leto", "beseda", "vzrok"),
    regex = "^(\\d{4})\\s(\\D{11})\\s+(.*)$"
  )
 
vzrok_smrti <- vzrok_smrti %>% select(spol, regija, leto, vzrok, stevilo.umrlih)

lepse = str_replace_all(vzrok_smrti$vzrok, "na", "Na")
vzrok_smrti$vzrok = lepse

vzrok_smrti <- vzrok_smrti %>% left_join(oznaka_spolov, by = c("spol"))
vzrok_smrti <- vzrok_smrti %>% select(spol = oznaka, regija, leto, vzrok, stevilo.umrlih)


################################# 6.tabela #################################
#1.tabela
svet_samomori <- read_csv("podatki/samomori_svet.csv", na="-",
         locale=locale(encoding="Windows-1250"), col_names =TRUE)

colnames(svet_samomori)[1] <- "drzava"
colnames(svet_samomori)[6] <- "leto"
colnames(svet_samomori)[7] <- "umrli"

svet_samomori <- svet_samomori %>% select(drzava, leto, umrli)


#2.tabela
bdp <- read_csv("podatki/bdp.csv", na="-",
                locale=locale(encoding="Windows-1250"), col_names =TRUE)

colnames(bdp)[1] <- "drzava"
colnames(bdp)[6] <- "leto"
colnames(bdp)[7] <- "vrednost.bdp"

bdp <- bdp %>% select(drzava, leto, vrednost.bdp)

# 1 + 2 tabela
svet <- merge(svet_samomori, bdp, all = TRUE)

svet$umrli <- as.character(svet$umrli)
svet$umrli[is.na(svet$umrli)] <- "ni.podatka"

svet$vrednost.bdp <- as.character(svet$vrednost.bdp)
svet$vrednost.bdp[is.na(svet$vrednost.bdp)] <- "ni.podatka"
