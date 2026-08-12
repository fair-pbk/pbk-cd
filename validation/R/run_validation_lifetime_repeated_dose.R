#-------------------------------------------------------------------------------
# Repeated dose scenario: simulation for 10 years (starting at age 0) with daily
# oral dose of 10 ug/kg BW day.
#-------------------------------------------------------------------------------

rm(list=ls())
set.seed(123)

library(data.table)
library(tidyr)
library(rxode2)
library(dplyr)

# CV model: the phys() function computes the time-varying inputs and assignment
# rules, passed as covariates in the event table.
source("validation/R/pbk_cv/Cd_Parameters_CV.R")
source("validation/R/pbk_cv/Time varying inputs and assignment rules_CV.R")
source("validation/R/pbk_cv/cd_pbk_shared_without source tracking_CV_v2.R")

results_path <- "validation/outputs/reference/R/"
results_file <- "oral_repeated_lifetime.csv"

# Scenario: single adult male, default parameters
sex_i <- 1          # Male
Delta_BWs3 <- 1.1   # Close to the mean Bw trajectory
Delta_creat <- 1    # Mean value

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
  UPTAKE1 = 0,
  PLASMA = 0,
  RBC = 0,
  META = 0,
  LIVER = 0,
  KIDNEY = 0,
  OTHER = 0,
  FECES = 0,
  URINE = 0
)

# Observed times: 10-year horizon from birth
time_val <- 0:(10*365)

# Pre-compute physiology covariates over the simulation period
phys_cov <- do.call(rbind, lapply(seq(0, max(time_val)), function(t) {
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

# Daily dose of 10 ug into GUT from birth to day 10*365
ev_init <- merge(
  data.frame(id = 1, time = 0:(10*365), evid = 1, cmt = "GUT", amt = 10),
  phys_cov,
  by = c("id", "time")
)

# Event table: every simulation time is an observation row with its physiology
# covariates; the doses add a second row at each dose time.
ev <- rbind(
  data.frame(phys_cov, evid = 0, amt = 0, cmt = NA),
  ev_init
)

ev <- ev[order(ev$id, ev$time), ]

# Solve
sim_output <- rxSolve(object = PBK1, params = theta, events = ev, inits = inits) %>%
  dplyr::filter(time %in% time_val) %>%
  dplyr::mutate(time = time_val)

## Create results path if not exists
if (!dir.exists(file.path(results_path))) {
  dir.create(file.path(results_path), recursive = TRUE)
}

# Write outputs
write.csv(sim_output, paste(results_path, results_file, sep=""))
