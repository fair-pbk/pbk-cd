
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
 
  d/dt(GUT) = (fabs_ing * king_release * DIET_ing* wbw_f + fabs_ing * king_release *SOIL_ing + fabs_ing * king_release * COSM_ing + fabs_ing * king_release * DUST_ing + fabs_inh * kinh_release *k1_cig * CIG_inhal_ing + fabs_inh * kinh_release * k1_dust * (AIR_inhal_ing * VInhalation) + k4 * LUNG)  - k5 * GUT;  # GI-tract
  
  # NEW
  d/dt(INTESTINE) = k5 * GUT - k6 * INTESTINE
    
  UPTAKE2=k8;
  if ((k7*UPTAKE1) <= k8) {UPTAKE2=k7*UPTAKE1;} # UPTAKE2 flow to metallothionein (b3) has a maximum = k8
  UPTAKE3 = UPTAKE1 - UPTAKE2; # UPTAKE3 goes to plasma pool (b1)
  
  # CHANGED: Simplified
  d/dt(UPTAKE1) =  k3*LUNG + k6*INTESTINE - UPTAKE1; # total uptake pool
  
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
  
  d/dt(FECES) = (1-k5)*GUT + k11*PLASMA + k15*LIVER;                                                             # feces
  
  d/dt(URINE) = META * k17b + KIDNEY * k19x;                                                        # urine cumulative
  
  ur = META * k17b + KIDNEY * k19x;                                                                 # Dose of Cd in urine (in ug)
  
  Conc_urine_cd = ur / Vurine;
  
  ucdcr = ur/ucr; 
  
  d/dt(EXH) = (1-k1-k2) * LUNG                                                                     # Exhalaltion
  
  total = GUT + LUNG + RBC + META + LIVER + KIDNEY + OTHER + FECES + URINE + PLASMA + UPTAKE1
  
})

# /Needs to be adjusted!!!!!!!!
sex_i <- 2
Delta_BWs3 <- 0.2
Delta_creat <- 0.2

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
  INTESTINA = 0,
  GUT = 0,
  UPTAKE1 = 0,
  PLASMA = Ccord * p0$vp0,
  RBC = Ccord * p0$vrbc0,
  META = 0,
  LIVER = 0,
  KIDNEY = 0,
  OTHER = 0,
  FECES = 0,
  URINE = 0,
  EXH = 0
)
