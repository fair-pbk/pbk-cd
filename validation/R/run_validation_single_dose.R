#-------------------------------------------------------------------------------
# Single dose scenario : simulation of 40 days for single adult age 30 with
# default parameters and single dose of 1 mg at time 0.
#-------------------------------------------------------------------------------

rm(list=ls())
set.seed(123)

library(data.table)
library(tidyr)
library(rxode2)
library(dplyr)

source("validation/R/cd_pbk_shared.R")

results_path <- "validation/outputs/oral_single"

ndays <- 40

df1 <- setDT(data.frame(id=1))
df1[, sex := 1] # Male
df1[, Delta_BWs3 := 1.1]  # Close to the mean Bw trajectory
df1[,Delta_creat := 1]    # Mean value
df1[,k2_cig:= 0.6]        # coeff smoke -> alveola. Not used in this scenario.
df1[,k1_dust := 0.9]      # Not used in this scenario.
df1[,k2_dust := 0.3]      # Not used in this scenario.
df1[,k3 := 0.05]
df1[,k4 := 0.005]
df1[,k5 := 0.05]
df1[,k6 := 0.05]
df1[,k7 := 0.25]
df1[,k8 := 1]
df1[,k9 := 0.44]
df1[,k10 := 0.00014]
df1[,k11 := 0.27]
df1[,k12 := 0.25]
df1[,kx := 0.04]
df1[,k13 := 0.00003]
df1[,k14 := 0.00016]
df1[,k15 := 0.00005]
df1[,k16:= 0.012]
df1[,k17:= 0.95]
df1[,k18:= 0.00001]
df1[,k19:= 0.00014]
df1[,k21:= 0.0000011]
df1[,k1_cig:= 0.1]       # Not used in this scenario.
df1[,k20 := 0.1]

# Key ages
uncount_dt <- function(dt, wt) {
  dt[rep(seq_len(.N), times = dt[[wt]]), ][, (wt) := NULL]
}
df1 %>%
  dplyr::ungroup() %>%
  dplyr::mutate(age_piv = 2) %>%
  as.data.table() %>%
  uncount_dt("age_piv") -> df1
age_piv_jour <- c(1,30*365)
df1 <- df1[, age_piv_jour:= floor(rep(age_piv_jour,.N / 2))]

# Food exposure (ug/d)
df1[,GUT := fifelse(age_piv_jour ==1,0,1000)]

# PBK input: Parameters table
params_all <- copy(df1)[
  ,
  .SD,
  .SDcols = c("id","sex","Delta_BWs3","Delta_creat","k2_cig","k1_dust",
              "k1_cig", "k2_dust","k3","k4","k5","k7","k8","k9","k10",
              "k11","k12","kx","k13","k14","k15","k16","k17","k18",
              "k19","k21","k20","k6")
][
  # garder une seule ligne par id_char_ind_unc
  , ndup := seq_len(.N), by = id
][
  ndup == 1
][
  , ndup := NULL
]

# PBK input 2: Influx event table
age_end <- 30*365+ndays # 30yo + 1 day.
event_res <- df1[, .(id, age_piv_jour,GUT)]
event_res <- melt(event_res, id.vars = c("id", "age_piv_jour"), 
                  variable.name = "SR_influx_name", value.name = "SR_influx_val")
event_res[, ii := 1]
event_res[, next_piv := shift(age_piv_jour, type = "lead", fill = age_end)-1, 
          by = .(id, SR_influx_name)]
event_res[, addl := 0]
event_res[, next_piv := NULL]
setnames(event_res, old = c("age_piv_jour", "SR_influx_name", "SR_influx_val"), 
         new = c("time", "cmt", "amt"))
event_res <- event_res[amt != 0]
setorder(event_res, id, time)
event_res[, time := time - 1]

# Observed times
time_val <- c(30*365,30*365+1:ndays)-1
time_obl <- seq(0,40000,length.out=250)
time_vect <- unique(c(time_val,time_obl))
ts_vector <- time_vect[order(time_vect)]

event_res %>%
  et() %>%
  et(ts_vector) %>%
  et(timeUnits="h") -> event_res

# Solve
sim_output <- rxSolve(object=PBK1, params=params_all, events=event_res) %>%
  dplyr::filter(time %in% time_val) %>%
  dplyr::mutate(time=(time_val - (30*365-1)))

## Create results path if not exists
if (!dir.exists(file.path(results_path))) {
  dir.create(file.path(results_path))
}

# Write outputs
write.csv(sim_output, paste(results_path, "/results_R.csv", sep=""))
