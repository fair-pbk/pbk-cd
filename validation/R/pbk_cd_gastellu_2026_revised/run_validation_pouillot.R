#-------------------------------------------------------------------------------
# Single dose scenario : simulation of 40 days for single adult age 30 with
# default parameters and single dose of 1 mg at time 0.
#-------------------------------------------------------------------------------

# Load packages
library(rxode2)
library(dplyr)
source("validation/R/pbk_cd_gastellu_2026_revised/default_parameters.R")
source("validation/R/pbk_cd_gastellu_2026_revised/time_varying_assignments.R")
source("validation/R/pbk_cd_gastellu_2026_revised/pbk_cd_gastellu_2026_revised.R")

# Write outputs
model_id <- "pbk_cd_gastellu_2026_revised"
results_path <- "validation/outputs/reference/R/oral_repeated_pouillot"

# Simulation setup

sex_i <- 1
Delta_BWs3 <- 1
Delta_creat <- 1

simulation_start <- 0*365 # days
simulation_end <- 80*365 # days
dose_end <- 50*365
dose_stepsize <- 10
observation_times <- seq(simulation_start, simulation_end, by = 1)


# Pre-compute physiology covariates
phys_cov <- do.call(rbind, lapply(observation_times, function(t) {
  
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

ev_lifetime <- data.frame(
  id = 1,
  time = seq(simulation_start,simulation_end,dose_stepsize),
  evid = 1,
  cmt = "GUT"
)

# Add observation rows before joining physiology so rxSolve receives a plain
# data frame with all required covariates.
ev_observed <- data.frame(
  id = 1,
  time = observation_times-simulation_start,
  evid = 0,
  cmt = NA_character_,
  amt = 0
)

phys_cov$time <- observation_times-simulation_start
event_res <- ev_lifetime %>%
  bind_rows(ev_observed) %>%
  left_join(phys_cov, by = c("id", "time")) %>%
  mutate(amt=0.2*dose_stepsize*wbw_f) %>%
  arrange(id, time, desc(evid))


# Solve
sim_output <- rxSolve(
  PBK1,
  params = theta,
  events = event_res,
  inits = inits
) 

## Create results path if not exists
if (!dir.exists(file.path(results_path))) {
  dir.create(file.path(results_path), recursive = TRUE)
}
write.csv(sim_output, paste(results_path, "/", model_id, ".csv", sep=""))
