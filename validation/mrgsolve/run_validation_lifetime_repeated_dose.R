#### SIMULATION OF LIFETIME DAILY BW-ADJUSTED CADMIUM EXPOSURE ####

suppressPackageStartupMessages(library(mrgsolve))
source("validation/mrgsolve/helper_functions.R")

results_path <- "validation/outputs/reference/mrgsolve/"
results_file <- "oral_repeated_lifetime.csv"

## Reading of PBK models
model <- mread("Model_Cd", file = "validation/mrgsolve/Model_Cd.cpp")

ndays <- 3650
sex <- 1
age_ref <- 30
bw_ref <- 85
Delta_BWs3 <- compute_delta_bw(age_ref, bw_ref, sex)
simulation_days <- 0:ndays
simulation_years <- simulation_days / 365
delta_bw <- ifelse(
  simulation_days <= 1095,
  1 + (Delta_BWs3 - 1) * (simulation_days / 1095),
  Delta_BWs3
)
body_weights <- vapply(
  simulation_years,
  function(year) compute_bw(year, sex),
  numeric(1)
) * delta_bw

## Extraction of cadmium dietary exposure for PBK modelling
expo_diet_cd <- ev(
  amt = rep(10, length(simulation_days)), # ug/kg bw/day; model scales by body weight
  ii = 1,
  cmt = "DIET",
  addl = 0
)
expo_diet_cd <- as_data_set(expo_diet_cd)
expo_diet_cd$time <- simulation_days
expo_diet_cd$year <- simulation_years
expo_diet_cd$wbw <- body_weights

## Estimation of the internal exposure of cadmium
sim_output <- model %>% param(SEXBABY = sex) %>%
  mrgsim(delta = 1/24, end = ndays, events = expo_diet_cd, output = 'df')

## Create results path if not exists
if (!dir.exists(file.path(results_path))) {
  dir.create(file.path(results_path), recursive = TRUE)
}

## Write output to CSV
write.csv(sim_output, paste(results_path, results_file, sep=""))
