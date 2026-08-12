# Draft simulation setup, moved out of cd_pbk_shared_without source tracking_CV_v2.R
# so that sourcing the model file only defines PBK1.
# Run from the repository root.
# NOTE: Ccord must be defined before running.

source("validation/R/pbk_cv/Cd_Parameters_CV.R")
source("validation/R/pbk_cv/Time varying inputs and assignment rules_CV.R")
source("validation/R/pbk_cv/cd_pbk_shared_without source tracking_CV_v2.R")

# /Needs to be adjusted!!!!!!!!

# Simulation setup

sex_i <- 2
Delta_BWs3 <- 0.2
Delta_creat <- 0.2

times <- seq(0, 80 * 365, by = 1)

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

# Optional birth/cord dose as time-zero bolus
ev_init <- data.frame(
  id = c(1, 1),
  time = c(0, 0),
  evid = c(1, 1),
  cmt = c("PLASMA", "RBC"),
  amt = c(Ccord * p0$vp0, Ccord * p0$vrbc0)
)

# Add physiology covariates to event table
ev <- merge(
  phys_cov,
  ev_init,
  by = c("id", "time"),
  all = TRUE
)

ev$evid[is.na(ev$evid)] <- 0
ev$amt[is.na(ev$amt)] <- 0
ev$cmt[is.na(ev$cmt)] <- NA

ev <- ev[order(ev$id, ev$time), ]

# Solve
out <- rxSolve(
  PBK1,
  params = theta,
  events = ev,
  inits = inits
)
