#### SIMULATION OF INTERNAL EXPOSURE FOR CADMIUM ####

library(mrgsolve)
library(dplyr)
library(readr)
library(ggplot2)
library(triangle)


### Tables for saving
Cd_Urinecr<- tibble()
Cd_Urine <- tibble()
Cd_Kidney <- tibble()
Cd_Blood <- tibble()

### Reading of PBK models
model_Cd <- mread("Model_Cd", file = "model/Model_Cd.cpp")

### Selection of exposure trajectories to different sources of exposure

for (i in c(1:10)){
  
  ## Extraction of cadmium dietary exposure for PBK modelling
  expo_diet_cd <- ev(amt = 100, 
                     ii=1,
                     cmt = "DIET", 
                     addl = 0)
  expo_diet_cd <- as_data_set(expo_diet_cd)
  expo_diet_cd$time <- 1
 
  
  ## Estimation of the internal exposure of cadmium
  Result_Cadmium <- model_Cd %>% param(wbw = 70, year = 30) %>%
    mrgsim(delta = 1, end = 10, events = expo_cd)
  
  Result_Cadmium <- as.data.frame(Result_Cadmium)
  Result_Cadmium <- Result_Cadmium[,c("time","ucdcr", "Conc_urine_cd","kidney_burden","BLOOD")] 
  Result_Cadmium <- aggregate(Result_Cadmium, by = list(Result_Cadmium$time), mean)
  
  Cd_Urinecr <- rbind(Cd_Urinecr, Result_Cadmium$ucdcr)
  Cd_Urine <- rbind(Cd_Urine, Result_Cadmium$Conc_urine_cd)
  Cd_Kidney <- rbind(Cd_Kidney, Result_Cadmium$kidney_burden)
  Cd_Blood <- rbind(Cd_Blood, Result_Cadmium$BLOOD)
  
  save(Cd_Urinecr, file = "Results/Cd_Urinecr_single.RData")
  save(Cd_Urine, file = "Results/Cd_Urine_single.RData")
  save(Cd_Kidney, file = "Results/Cd_Kidney_single.RData")
  save(Cd_Blood, file = "Results/Cd_Blood_single.RData")
  
  print(i)
}
