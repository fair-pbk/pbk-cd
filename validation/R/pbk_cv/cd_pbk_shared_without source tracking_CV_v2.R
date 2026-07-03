
# 1. Without source-route tracking
PBK1 <- rxode2({ 

  # ODE ----
 
  d/dt(AIR_inhal_ing) = - kinh_release * AIR_inhal_ing; # Exposure by inhalation (µg/L)
  d/dt(CIG_inhal_ing) = - kinh_release * CIG_inhal_ing; # NEW ITEM
 
  d/dt(DIET_ing) = - king_release * DIET_ing ; # Dietary exposure (µg/kg)
  d/dt(SOIL_ing) = - king_release * SOIL_ing; # Exposure by soil (µg)
  d/dt(DUST_ing) = - king_release * DUST_ing; # Exposure by dust (µg)
  d/dt(COSM_ing) = - king_release * COSM_ing; # NEW ITEM (µg)
  
  d/dt(AIR_derm) = - kderm_release * AIR_derm; # NEW ITEM
  d/dt(DUST_derm) = - kderm_release * DUST_derm; # NEW ITEM
  d/dt(COSM_derm) = - kderm_release * COSM_derm; # NEW ITEM
  # Added CORD_quant explicitly as initial amount
  #d/dt(CORD_quant) = - CORD_quant; # NEW ITEM
  
  
  d/dt(LUNG) = fabs_inh *kinh_release * k2_dust*(AIR_inhal_ing * VInhalation) + fabs_inh *kinh_release * k2_cig * CIG_inhal_ing - LUNG*(k3 + k4);           # pulmonary region at t=T
  
  # NEW item: COSM ing.
  GI_Input = (fabs_ing * king_release * DIET_ing* wbw_f + fabs_ing * king_release *SOIL_ing + fabs_ing * king_release * COSM_ing + fabs_ing * king_release * DUST_ing + fabs_inh * kinh_release *k1_cig * CIG_inhal_ing + fabs_inh * kinh_release * k1_dust * (AIR_inhal_ing * VInhalation) + k4 * LUNG) 
  d/dt(GUT) = k5 * GI_Input - k6 * GUT;  # GI-tract
  
  
  UPTAKE2=k8;
  if ((k7*UPTAKE1) <= k8) {UPTAKE2=k7*UPTAKE1;} # UPTAKE2 flow to metallothionein (b3) has a maximum = k8
  UPTAKE3 = UPTAKE1 - UPTAKE2; # UPTAKE3 goes to plasma pool (b1)
  
  # CHANGED: Simplified
  d/dt(UPTAKE1) =  k3*LUNG + k6*GUT - UPTAKE1; # total uptake pool
  
  # NEW ITEM: DERMAL absorption.
  # NEW ITEM: Exposure at birth. This can likely be implemented differently, 
  # depending on whether it is viewed as an initial condition or an exposure event.
  # Added +k18*KIDNEY
  d/dt(PLASMA) = UPTAKE3 + k10 * OTHER + k13 * LIVER + k18 * KIDNEY - k9*PLASMA - k11 * PLASMA - k12 * PLASMA - kx * PLASMA + fabs_derm * kderm_release *AIR_derm + fabs_derm * kderm_release * DUST_derm + fabs_derm * kderm_release * COSM_derm;                   # Plasma
  
  # NEW ITEM: Exposure at birth. This can likely be implemented differently, 
  # depending on whether it is viewed as an initial condition or an exposure event.
  d/dt(RBC) = PLASMA * kx - k16 * RBC;                                                              # Red Blood Cells
  
  d/dt(META) = UPTAKE2 + k14 * LIVER + k16 * RBC - k17x * META - k17b * META;                       # Metallothionein
  
  # Changed - erased /vb
  BLOOD = (RBC + k20 * (PLASMA + META));                                                            # total blood amount
  
  BLOOD_burden = (RBC + k20 * (PLASMA + META))/vb; 
  
  d/dt(LIVER) = k12 * PLASMA - (k13 + k14 + k15) * LIVER;                                           # Liver
  
  d/dt(KIDNEY) = k17x*META - k18 *KIDNEY - k19x * KIDNEY;                                           # Kidney
  
  kidney_burden = (KIDNEY)/vk;                                                                      # kidney burden in ug/kg
  
  d/dt(OTHER) = k9 * PLASMA - k10 * OTHER;                                                          # other tissues
  
  #wb = BLOOD + LIVER + KIDNEY + OTHER + LUNG + GUT;                                                # body burden is actually total
  
  d/dt(FECES) = k11*PLASMA + k15*LIVER;                                                             # feces
  
  d/dt(URINE) = META * k17b + KIDNEY * k19x;                                                        # urine cumulative
  
  ur = META * k17b + KIDNEY * k19x;                                                                 # Dose of Cd in urine (in ug)
  
  Conc_urine_cd = ur / Vurine;
  
  ucdcr = ur/ucr; 
  
  total = GUT + LUNG + RBC + META + LIVER + KIDNEY + OTHER + FECES + URINE + PLASMA + UPTAKE1

})

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