#### SIMULATION OF INTERNAL EXPOSURE FOR CADMIUM ####

library(mrgsolve)
library(dplyr)
library(readr)
library(ggplot2)
library(triangle)

load("Exposure trajectories/pop_save_4ETM_daily_diet_soil_air_dust_INCA2.RData")

### Selection of population parameters 
# Gender
sexes <- sapply(pop_ref, function(x) x$sexe)
sexes <- as.vector(t(sexes))
sexes[sexes==2]<-0
sexes <- as.integer(sexes[1:10])

# Year of birth
annee_naiss <- sapply(pop_ref, function(x) x$annee_naiss)

# Region of habitation
region <- sapply(pop_ref, function(x) x$reg)

### Tables for saving
Cd_Urinecr<- tibble()
Cd_Urine <- tibble()
Cd_Kidney <- tibble()
Cd_Blood <- tibble()

### Reading of PBK models
model_Cd <- mread("Model_Cd", file = "PBK models/Model_Cd.cpp")

### Selection of exposure trajectories to different sources of exposure
# Air contaminations are in ng/m3;
# Soil and dust contamination are in µg/g of soil/dust;
# Dietary exposure is in µg/kg/day.
traj_diet_cd <- sapply(pop_ref, function(x) x$expo_cd)
traj_soil_cd <- sapply(pop_ref, function(x) x$soil_cd)
traj_dust_cd <- sapply(pop_ref, function(x) x$dust_cd)
traj_air_cd <- sapply(pop_ref, function(x) x$air_cd/1000000) 


rm(pop_ref)


for (i in c(1:10)){
  
  ## Determination of the factor of distribution of individuals
  
  # Bodyweight
  Delta_BW_ind = rnorm(1, mean = 1, sd = 0.15)
  
  # Creatinine excretion
  Delta_creat_ind = rnorm(1, mean = 1, sd = 0.15)
  
  ## Variability for male
  Delta_Brain_M_ind = abs(rnorm(1, mean = 1, sd = 0.05))
  Delta_Kidney_M_ind = abs(rnorm(1, mean = 1, sd = 0.25))
  Delta_Liver_M_ind = abs(rnorm(1, mean = 1, sd = 0.24))
  Delta_Pancreas_M_ind = abs(rnorm(1, mean = 1, sd = 0.27))
  Delta_Stomach_M_ind = abs(rnorm(1, mean = 1, sd = 0.31))
  Delta_Small_Intestine_M_ind = abs(rnorm(1, mean = 1, sd = 0.12))
  Delta_Large_Intestine_M_ind = abs(rnorm(1, mean = 1, sd = 0.20))
  Delta_Heart_M_ind = abs(rnorm(1, mean = 1, sd = 0.19))
  Delta_Bone_M_ind = abs(rnorm(1, mean = 1, sd = 0.01))
  Delta_Gonad_M_ind = abs(rnorm(1, mean = 1, sd = 0.05))
  Delta_Lung_M_ind = abs(rlnorm(1, mean = 1, sd = .33))
  Delta_Spleen_M_ind = abs(rlnorm(1, mean = 1, sd = .38))
  Delta_Muscle_M_ind = abs(rnorm(1, mean = 1, sd = .27))
  Delta_Adipose_M_ind = abs(rnorm(1, mean = 1, sd = .42))
  
  ## Variability for female
  Delta_Brain_F_ind = abs(rnorm(1, mean = 1, sd = 0.05))
  Delta_Kidney_F_ind = abs(rnorm(1, mean = 1, sd = 0.25))
  Delta_Liver_F_ind = abs(rnorm(1, mean = 1, sd = 0.25))
  Delta_Pancreas_F_ind = abs(rnorm(1, mean = 1, sd = .29))
  Delta_Stomach_F_ind = abs(rnorm(1, mean = 1, sd = .31))
  Delta_Small_Intestine_F_ind = abs(rnorm(1, mean = 1, sd = .13))
  Delta_Large_Intestine_F_ind = abs(rnorm(1, mean = 1, sd = .14))
  Delta_Heart_F_ind = abs(rnorm(1, mean = 1, sd = .25))
  Delta_Bone_F_ind = abs(rnorm(1, mean = 1, sd = .01))
  Delta_Gonad_F_ind = abs(rnorm(1, mean = 1, sd = .05))
  Delta_Lung_F_ind = abs(rlnorm(1, mean = 1, sd = .33))
  Delta_Spleen_F_ind = abs(rlnorm(1, mean = 1, sd = .38))
  Delta_Muscle_F_ind = abs(rlnorm(1, mean = 1, sd = .27))
  Delta_Adipose_F_ind = abs(rlnorm(1, mean = 1, sd = .42))
  
  ## Quantity of soil and dust ingested (in g/day)
  conso_soil <- matrix(data = NA, ncol = 1, nrow = 29094)
  conso_dust <- matrix(data = NA, ncol = 1, nrow = 29094)
  
  for (t in c(1:29094)){
    age = t/365
    if(age < 1/12){
      conso_soil[t] <- 0
      conso_dust[t] <- sqrt(rnorm(1,32,44)**2)/1000
    }
    if(age >= 1/12 & age < 3/12){
      conso_soil[t] <- 0
      conso_dust[t] <- sqrt(rnorm(1,36,53)**2)/1000
    }
    if(age >= 3/12 & age < 0.5){
      conso_soil[t] <- 0
      conso_dust[t] <- sqrt(rnorm(1,37,47)**2)/1000
    }
    if(age >= 0.5 & age < 1){
      conso_soil[t] <- 0
      conso_dust[t] <- sqrt(rnorm(1,44,70)**2)/1000
    }
    if(age >= 1 & age < 2){
      conso_soil[t] <- sqrt(rnorm(1,10,16)**2)/1000
      conso_dust[t] <- sqrt(rnorm(1,37,54)**2)/1000
    }
    if(age >= 2 & age < 3){
      conso_soil[t] <- sqrt(rnorm(1,27,39)**2)/1000
      conso_dust[t] <- sqrt(rnorm(1,26,45)**2)/1000
    }
    if(age >= 3 & age < 6){
      conso_soil[t] <- sqrt(rnorm(1,31,48)**2)/1000
      conso_dust[t] <- sqrt(rnorm(1,28,40)**2)/1000
    }
    if(age >= 6 & age < 11){
      conso_soil[t] <- sqrt(rnorm(1,31,54)**2)/1000
      conso_dust[t] <- sqrt(rnorm(1,25,38)**2)/1000
    }
    if(age >= 11 & age < 16){
      conso_soil[t] <- sqrt(rnorm(1,23,45)**2)/1000
      conso_dust[t] <- sqrt(rnorm(1,21,41)**2)/1000
    }
    if(age >= 16 & age < 21){
      conso_soil[t] <- sqrt(rnorm(1,12,33)**2)/1000
      conso_dust[t] <- sqrt(rnorm(1,11,27)**2)/1000
    }
    if(age>=21){
      conso_soil[t] <- 0
      conso_dust[t] <- 0
    }	
    
  }
  
  
  ## Establishment of daily exposure by soil with refined with time
  for(j in c(1 : 29094)){
    x <- as.numeric(annee_naiss[i]) + j/365
    if(x < 2005){
      traj_soil_cd[j,i] <- traj_soil_cd[j,i]*(1 - 0.005*(2005 - x)) * conso_soil[j]

    }
    else{
      traj_soil_cd[j,i] <- traj_soil_cd[j,i] * conso_soil[j]
    }
  }
  
  ## Extrapolation of air contamination over time
  Conta_Cd_NO <- function(x){-5.061e-06 * x^2 + 1.307e-02 * x -5.406e+00} 
  Conta_Cd_O <- function(x){-7.452e-05 * x^2 + 2.909e-01 * x -2.834e+02} 
  Conta_Cd_E <- function(x){-2.577e-04 * x^2 + 1.007e+00 * x -9.822e+02} 
  Conta_Cd_IdF <- function(x){-1.039e-04 * x^2 + 4.037e-01 * x -3.915e+02} 
  Conta_Cd_CE <- function(x){-1.469e-04 * x^2 + 5.737e-01 * x -5.592e+02} 
  Conta_Cd_SE <- function(x){-1.872e-04 * x^2 + 7.308e-01 * x -7.1225e+02} 
  Conta_Cd_SO <- function(x){-3.073e-04 * x^2 + 1.198e+00 * x -1.165e+03} 
  Conta_Cd_C <- function(x){-1.034e-04 * x^2 +  4.018e-01 * x -3.894e+02} 
  
  ## ## Establishment of daily exposure by dust scaled on air  with refined with time
  for(j in c(1:29120)){
    x <- as.numeric(annee_naiss[i]) + j/365
    if(x < 2020){
      
      if(region[j,i] == 0){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_NO(x)/Conta_Cd_NO(2009))}
      
      if(region[j,i] == 1){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_E(x)/Conta_Cd_E(2009))}
      
      if(region[j,i] == 2){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_IdF(x)/Conta_Cd_IdF(2009))}
      
      if(region[j,i] == 3){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_O(x)/Conta_Cd_O(2009))}
      
      if(region[j,i] == 4){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_C(x)/Conta_Cd_C(2009))}
      
      if(region[j,i] == 5){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_CE(x)/Conta_Cd_CE(2009))}
      
      if(region[j,i] == 6){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_SO(x)/Conta_Cd_SO(2009))}
      
      if(region[j,i] == 7){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_SE(x)/Conta_Cd_SE(2009))}
    }
    
    else{
      if(region[j,i] == 0){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_NO(2020)/Conta_Cd_NO(2009))}
      
      if(region[j,i] == 1){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_E(2020)/Conta_Cd_E(2009))}
      
      if(region[j,i] == 2){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_IdF(2020)/Conta_Cd_IdF(2009))}
      
      if(region[j,i] == 3){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_O(2020)/Conta_Cd_O(2009))}
      
      if(region[j,i] == 4){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_C(2020)/Conta_Cd_C(2009))}
      
      if(region[j,i] == 5){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_CE(2020)/Conta_Cd_CE(2009))}
      
      if(region[j,i] == 6){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_SO(2020)/Conta_Cd_SO(2009))}
      
      if(region[j,i] == 7){
        traj_dust_cd[j,i] <- traj_dust_cd[j,i] * conso_dust[j] * (Conta_Cd_SE(2020)/Conta_Cd_SE(2009))}
    }
  }
  
  
  ## Extraction of cadmium dietary exposure for PBK modelling
  expo_diet_cd <- ev(amt = (traj_diet_cd[,i]), 
                     ii=1,
                     cmt = "DIET", 
                     addl = 0)
  expo_diet_cd <- as_data_set(expo_diet_cd)
  expo_diet_cd$time <- c(0:29093)
  
  ## Extraction of cadmium exposure by soil for PBK modelling
  expo_soil_cd <- ev(amt =(traj_soil_cd[c(1:29094),i]), 
                     ii=1,  
                     cmt = "SOIL", 
                     addl = 0)
  expo_soil_cd <- as_data_set(expo_soil_cd)
  expo_soil_cd$time <- c(0:29093)
  
  ## Extraction of cadmium exposure by air for PBK modelling
  expo_air_cd <- ev(amt = (traj_air_cd[c(1:29094),i]), 
                    ii=1,
                    cmt = "AIR", 
                    addl = 0)
  expo_air_cd <- as_data_set(expo_air_cd)
  expo_air_cd$time <- c(0:29093)
  
  ## Extraction of cadmium exposure by dust for PBK modelling
  expo_dust_cd <- ev(amt = (traj_dust_cd[c(1:29094),i]), 
                     ii=1,
                     cmt = "DUST", 
                     addl = 0)
  expo_dust_cd <- as_data_set(expo_dust_cd)
  expo_dust_cd$time <- c(0:29093)
  
  ## Compilation of cadmium exposures
  expo_cd <- rbind(expo_diet_cd, expo_soil_cd, expo_air_cd, expo_dust_cd)
  expo_cd <- expo_cd[order(expo_cd$time),]
  
  
  ## Estimation of the internal exposure of cadmium
  Result_Cadmium <- model_Cd %>% param(Delta_BW         = Delta_BW_ind,
                                       Delta_creat      = Delta_creat_ind, 
                                       k1_cig           = rtriangle(1,0.1,0.2,0.1),
                                       k1_dust          = rtriangle(1,0.4,0.9,0.7),
                                       k2_cig           = rtriangle(1,0.4,0.6,0.4),
                                       k2_dust          = rtriangle(1,0.1,0.3,0.13),
                                       k3               = rtriangle(1,0.01,1,0.05),
                                       k4               = rtriangle(1,0.001,0.1,0.005),
                                       k5_h             = rtriangle(1,0.03,0.1,0.05),
                                       k5_f             = rtriangle(1,0.06,0.20,0.10),
                                       k7               = rtriangle(1,0.2,0.4,0.25), 
                                       k8               = rtriangle(1,0.5,5,1),
                                       k9               = rtriangle(1,0.4,0.8,0.44),
                                       k10              = rtriangle(1,0.00004,0.0002,0.00014),
                                       k11              = rtriangle(1,0.05,0.5,0.27),
                                       k12              = rtriangle(1,0.1,0.4,0.25),
                                       kx               = rtriangle(1,0.01,0.05,0.04),
                                       k13              = rtriangle(1,0,0.0001,0.00003),
                                       k14              = rtriangle(1,0.0001,0.0003,0.00016),
                                       k15              = rtriangle(1,0,0.0001,0.00005),
                                       k16              = rtriangle(1,0.004,0.015,0.012),
                                       k17              = rtriangle(1,0.8,0.98,0.95),
                                       k18              = rtriangle(1,0,0.0001,0.00001),
                                       k19              = rtriangle(1,0.00002,0.0002,0.00014),
                                       k21              = rtriangle(1,0,0.000002,0.0000011),
                                       age_deb          = 0,   ## Beginning of smoking (years)
                                       age_fin          = 0,   ## End of smoking (years)
                                       kcig             = 0.1, ## Coefficient of absorption by smoking
                                       smoke_cd         = 1,   ## Quantity of cadmium in one cigaret (in µg)
                                       nb_cig           = 0,   ## Number of cigarets smoked by day
                                       Delta_Brain_M    = Delta_Brain_M_ind,
                                       Delta_Kidney_M   = Delta_Kidney_M_ind,
                                       Delta_Liver_M    = Delta_Liver_M_ind,
                                       Delta_Pancreas_M = Delta_Pancreas_M_ind,
                                       Delta_Stomach_M  = Delta_Stomach_M_ind,
                                       Delta_Small_Intestine_M = Delta_Small_Intestine_M_ind,
                                       Delta_Large_Intestine_M = Delta_Large_Intestine_M_ind,
                                       Delta_Heart_M    = Delta_Heart_M_ind,
                                       Delta_Bone_M     = Delta_Bone_M_ind,
                                       Delta_Gonad_M    = Delta_Gonad_M_ind,
                                       Delta_Lung_M     = Delta_Lung_M_ind,
                                       Delta_Spleen_M   = Delta_Spleen_M_ind,
                                       Delta_Muscle_M   = Delta_Muscle_M_ind,
                                       Delta_Adipose_M  = Delta_Adipose_M_ind,
                                       Delta_Brain_F    = Delta_Brain_F_ind,
                                       Delta_Kidney_F   = Delta_Kidney_F_ind,
                                       Delta_Liver_F    = Delta_Liver_F_ind,
                                       Delta_Pancreas_F = Delta_Pancreas_F_ind,
                                       Delta_Stomach_F  = Delta_Stomach_F_ind,
                                       Delta_Small_Intestine_F = Delta_Small_Intestine_F_ind,
                                       Delta_Large_Intestine_F = Delta_Large_Intestine_F_ind,
                                       Delta_Heart_F    = Delta_Heart_F_ind,
                                       Delta_Bone_F     = Delta_Bone_F_ind,
                                       Delta_Gonad_F    = Delta_Gonad_F_ind,
                                       Delta_Lung_F     = Delta_Lung_F_ind,
                                       Delta_Spleen_F   = Delta_Spleen_F_ind,
                                       Delta_Muscle_F   = Delta_Muscle_F_ind,
                                       Delta_Adipose_F  = Delta_Adipose_F_ind,
                                       SEXBABY = sexes[i]) %>%
    mrgsim(delta = 1, end = 29094, events = expo_cd)
  
  Result_Cadmium <- as.data.frame(Result_Cadmium)
  Result_Cadmium <- Result_Cadmium[,c("time","ucdcr", "Conc_urine_cd","kidney_burden","BLOOD")] 
  Result_Cadmium <- aggregate(Result_Cadmium, by = list(Result_Cadmium$time), mean)
  
  Cd_Urinecr <- rbind(Cd_Urinecr, Result_Cadmium$ucdcr)
  Cd_Urine <- rbind(Cd_Urine, Result_Cadmium$Conc_urine_cd)
  Cd_Kidney <- rbind(Cd_Kidney, Result_Cadmium$kidney_burden)
  Cd_Blood <- rbind(Cd_Blood, Result_Cadmium$BLOOD)
  
  save(Cd_Urinecr, file = "Results/Cd_Urinecr_aggregated.RData")
  save(Cd_Urine, file = "Results/Cd_Urine_aggregated.RData")
  save(Cd_Kidney, file = "Results/Cd_Kidney_aggregated.RData")
  save(Cd_Blood, file = "Results/Cd_Blood_aggregated.RData")
  
  print(i)
} 
