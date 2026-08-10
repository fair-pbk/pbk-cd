#### SIMULATION OF INTERNAL EXPOSURE FOR CADMIUM ####

library(mrgsolve)

results_path <- "validation/outputs/reference/mrgsolve/"
results_file <- "oral_single.csv"

## Reading of PBK models
model <- mread("Model_Cd", file = "validation/mrgsolve/Model_Cd.cpp")

## Extraction of cadmium dietary exposure for PBK modelling
expo_diet_cd <- ev(
  amt = 1000,
  ii = 1,
  cmt = "GUT",
  addl = 0
)
expo_diet_cd <- as_data_set(expo_diet_cd)
expo_diet_cd$time <- 0

## Estimation of the internal exposure of cadmium
sim_output <- model %>% param(wbw = 85, year = 30) %>%
  mrgsim(delta = 1/24, end = 40, events = expo_diet_cd, output = 'df')

## Create results path if not exists
if (!dir.exists(file.path(results_path))) {
  dir.create(file.path(results_path), recursive = TRUE)
}

## Write output to CSV
write.csv(sim_output, paste(results_path, results_file, sep=""))
