
# 1. Without source-route tracking
PBK1 <- rxode2({ 

  # ODE ----
 
  d/dt(AIR_inhal_ing) = - kinh_release * AIR_inhal_ing; # Exposure by inhalation.   AIR_inhal_ing UNIT: µg/L.
  d/dt(CIG_inhal_ing) = - kinh_release * CIG_inhal_ing; #                           CIG_inhal_ing UNIT: µg.
 
  d/dt(DIET_ing) = - king_release * DIET_ing ; # Dietary exposure (µg/kg)                DIET_ing UNIT: µg/kg.
  d/dt(SOIL_ing) = - king_release * SOIL_ing; # Exposure by soil (µg)                    SOIL_ing UNIT: µg.             
  d/dt(DUST_ing) = - king_release * DUST_ing; # Exposure by dust (µg)                    DUST_ing UNIT: µg.
  d/dt(COSM_ing) = - king_release * COSM_ing; # NEW ITEM (µg)                            COSM_ing UNIT: µg.
  
  d/dt(AIR_derm) = - kderm_release * AIR_derm; # NEW ITEM                                AIR_derm UNIT: µg.
  d/dt(DUST_derm) = - kderm_release * DUST_derm; # NEW ITEM                              DUST_derm UNIT: µg.
  d/dt(COSM_derm) = - kderm_release * COSM_derm; # NEW ITEM                              COSM_derm UNIT: µg.
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
