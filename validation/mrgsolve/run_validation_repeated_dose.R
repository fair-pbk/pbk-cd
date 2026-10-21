#### SIMULATION OF INTERNAL EXPOSURE FOR CADMIUM ####

suppressPackageStartupMessages(library(mrgsolve))
source("validation/R/pbk_cd_gastellu_2026_revised/helper_functions.R")
bw_start <- compute_bw(30, 1)

results_path <- "validation/outputs/reference/mrgsolve/"
results_file <- "oral_repeated.csv"

## Reading of PBK models
model <- mread("Model_Cd", file = "validation/mrgsolve/Model_Cd.cpp")

## Extraction of cadmium dietary exposure for PBK modelling
expo_diet_cd <- ev(
  amt = rep(100 / bw_start, 41), # ug/kg bw, as in the original R implementation
  ii = 1,
  cmt = "DIET",
  addl = 0
)
expo_diet_cd <- as_data_set(expo_diet_cd)
expo_diet_cd$time <- c(0:40)
expo_diet_cd$wbw <- 85
expo_diet_cd$year <- 30

## Estimation of the internal exposure of cadmium
sim_output <- model %>% param(SEXBABY = 1) %>%
  mrgsim(delta = 1/24, end = 40, events = expo_diet_cd, output = 'df')

## Create results path if not exists
if (!dir.exists(file.path(results_path))) {
  dir.create(file.path(results_path), recursive = TRUE)
}

## Write output to CSV
write.csv(sim_output, paste(results_path, results_file, sep=""))
