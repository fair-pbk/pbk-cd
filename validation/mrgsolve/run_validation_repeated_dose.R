#### SIMULATION OF INTERNAL EXPOSURE FOR CADMIUM ####

library(mrgsolve)

results_path <- "validation/outputs/oral_repeated"

## Reading of PBK models
model <- mread("Model_Cd", file = "model/Model_Cd.cpp")

## Extraction of cadmium dietary exposure for PBK modelling
expo_diet_cd <- ev(
  amt = rep(100, 10), 
  ii = 1,
  cmt = "DIET",
  addl = 0
)
expo_diet_cd <- as_data_set(expo_diet_cd)
expo_diet_cd$time <- c(1:10)

## Estimation of the internal exposure of cadmium
sim_output <- model %>% param(wbw = 70, year = 30) %>%
  mrgsim(delta = 1/24, end = 10, events = expo_diet_cd, output = 'df')

## Create results path if not exists
if (!dir.exists(file.path(results_path))) {
  dir.create(file.path(results_path))
}

## Write output to CSV
write.csv(sim_output, paste(results_path, "/results_mrgsolve.csv", sep=""))
