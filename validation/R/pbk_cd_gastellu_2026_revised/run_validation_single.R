#-------------------------------------------------------------------------------
# Single dose scenario : simulation of 40 days for single adult age 30 with
# default parameters and single dose of 1 mg at time 0.
#-------------------------------------------------------------------------------

# Load packages
library(rxode2)
library(dplyr)
source("validation/R/pbk_cd_gastellu_2026_revised/Cd_Parameters_CV.R")
source("validation/R/pbk_cd_gastellu_2026_revised/Time varying inputs and assignment rules_CV.R")
source("validation/R/pbk_cd_gastellu_2026_revised/pbk_cd_gastellu_2026_revised.R")



# /Needsrxode2# /Needs to be adjusted!!!!!!!!

# Simulation setup

sex_i <- 1
Delta_BWs3 <- 1
Delta_creat <- 1

ndays <- 40 # days
age_start <- 30 # years
age_start_days <- age_start * 365
times <- seq(age_start_days, age_start_days + ndays, by = 1)

# Pre-compute physiology covariates
phys_cov <- do.call(rbind, lapply(times, function(t) {
  
  p <- phys(
    time = t,
    sex = sex_i,
    Delta_BWs3 = Delta_BWs3,
    Delta_creat = Delta_creat,
    k5_h = unname(theta["k5_h"]),
    k5_f = unname(theta["k5_f"]),
    k17  = unname(theta["k17"]),
    k19  = unname(theta["k19"]),
    k21  = unname(theta["k21"])
  )
  
  data.frame(
    id = 1,
    time = t,
    wbw_f = p$wbw_f,
    vb = p$vb,
    vk = p$vk,
    VInhalation = p$VInhalation,
    Vurine = p$Vurine,
    ucr = p$ucr,
    k5 = p$k5,
    k17x = p$k17x,
    k17b = p$k17b,
    k19x = p$k19x
  )
}))

# Initial physiology at birth
p0 <- phys(
  time = 0,
  sex = sex_i,
  Delta_BWs3 = Delta_BWs3,
  Delta_creat = Delta_creat,
  k5_h = unname(theta["k5_h"]),
  k5_f = unname(theta["k5_f"]),
  k17  = unname(theta["k17"]),
  k19  = unname(theta["k19"]),
  k21  = unname(theta["k21"])
)

# Initial states
inits <- c(
  DIET_ing = 0,
  AIR_inhal_ing = 0,
  CIG_inhal_ing = 0,
  SOIL_ing = 0,
  DUST_ing = 0,
  COSM_ing = 0,
  AIR_derm = 0,
  DUST_derm = 0,
  COSM_derm = 0,
  LUNG = 0,
  GUT = 0,
  INTESTINE = 0,
  UPTAKE1 = 0,
  PLASMA = 0,
  RBC = 0,
  META = 0,
  LIVER = 0,
  KIDNEY = 0,
  OTHER = 0,
  FECES = 0,
  URINE = 0,
  EXH = 0
)

ev_bolus_single <- data.frame(
  id = c(1),
  time = 0,
  evid = c(1),
  cmt = c("GUT"),
  amt = c(1000)
)

# Add observation rows separately so each dose time is also sampled.
ev_observed <- data.frame(
  id = 1,
  time = seq(0, ndays, by = 1),
  evid = 0,
  cmt = NA_character_,
  amt = 0
)

ev_single<- bind_rows(ev_bolus_single, ev_observed)

# Add physiology covariates to every event and observation row
phys_cov$time <- phys_cov$time - age_start_days
ev_single <- ev_single %>%
  left_join(phys_cov, by = c("id", "time")) %>%
  arrange(id, time, desc(evid))

# Solve
sim_output <- rxSolve(
  PBK1,
  params = theta,
  events = ev_single,
  inits = inits
)

# Write outputs
model_id <- "pbk_cd_gastellu_2026_revised"
results_path <- "validation/outputs/reference/R/oral_single"

## Create results path if not exists
if (!dir.exists(file.path(results_path))) {
  dir.create(file.path(results_path), recursive = TRUE)
}

write.csv(sim_output, paste(results_path, "/", model_id, ".csv", sep=""))
