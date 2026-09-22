
# 1. Without source-route tracking
PBK1 <- rxode2({ 
  
  # ODE ----
  
  # Exposure source compartments
  d/dt(AIR_inhal_ing) = - kinh_release * AIR_inhal_ing; # Exposure by inhalation (µg/L)
  d/dt(CIG_inhal_ing) = - kinh_release * CIG_inhal_ing; # NEW ITEM (µg)
  
  d/dt(DIET_ing) = - king_release * DIET_ing ; # Dietary exposure (µg/kg)
  d/dt(SOIL_ing) = - king_release * SOIL_ing; # Exposure by soil (µg)
  d/dt(DUST_ing) = - king_release * DUST_ing; # Exposure by dust (µg)
  d/dt(COSM_ing) = - king_release * COSM_ing; # NEW ITEM (µg)
  
  d/dt(AIR_derm) = - kderm_release * AIR_derm; # NEW ITEM
  d/dt(DUST_derm) = - kderm_release * DUST_derm; # NEW ITEM
  d/dt(COSM_derm) = - kderm_release * COSM_derm; # NEW ITEM
  # Added CORD_quant explicitly as initial amount
  #d/dt(CORD_quant) = - CORD_quant; # NEW ITEM
  
  # Respiratory tract
  d/dt(LUNG) = f_inh_available * k2_dust * AIR_inhal_ing * VInhalation + 
    f_inh_available * kinh_release * k2_cig * CIG_inhal_ing - 
    LUNG*(k3 + k4);          
  
  # GI Input
  GI_input = 
    f_ing_available * king_release * DIET_ing * wbw_f + 
    f_ing_available * king_release * SOIL_ing + 
    f_ing_available * king_release * COSM_ing + 
    f_ing_available * king_release * DUST_ing +
    f_inh_available * kinh_release * k1_cig * CIG_inhal_ing + 
    f_inh_available * k1_dust * AIR_inhal_ing * VInhalation + 
    k4 * LUNG;
  
  d/dt(GUT) = GI_input - kabs * GUT; # GI-tract # NEW V3: added kabs for unity consistency; kabs = 1 1/day
  
  # NEW
  d/dt(INTESTINE) = k5 * kabs * GUT - k6 * INTESTINE; # NEW V3: added kabs for unity consistency; kabs = 1 1/day
  
  # Total systemic input  
  TOTAL_UPTAKE = k3 * LUNG + k6 * INTESTINE; # NEW V3; in µg/day
  
  UPTAKE_MT = k8;
  if ((k7*TOTAL_UPTAKE) <= k8) {UPTAKE_MT=k7*TOTAL_UPTAKE;} # UPTAKE_MT flux to metallothionein has a maximum = k8; in µg/day
  
  UPTAKE_PLASMA = TOTAL_UPTAKE - UPTAKE_MT; # UPTAKE_Plasma goes to plasma pool (b1)
  
  # CHANGED: Simplified -> Taken out and replaced by total_uptake
  # d/dt(Total_UPTAKE) =  k3*LUNG + k6*INTESTINE - Total_UPTAKE; # total uptake pool
  
  # NEW ITEM: DERMAL absorption.
  # NEW ITEM: Exposure at birth. This can likely be implemented differently, 
  # depending on whether it is viewed as an initial condition or an exposure event.
  # Added +k18*KIDNEY
  
  #Plasma
  d/dt(PLASMA) = UPTAKE_PLASMA + 
    k10 * OTHER + 
    k13 * LIVER + 
    k18 * KIDNEY - 
    k9*PLASMA - 
    k11 * PLASMA - 
    k12 * PLASMA - 
    kx * PLASMA + 
    f_derm_available * kderm_release *AIR_derm + 
    f_derm_available * kderm_release * DUST_derm + 
    f_derm_available * kderm_release * COSM_derm;                   
  
  # NEW ITEM: Exposure at birth. This can likely be implemented differently, 
  # depending on whether it is viewed as an initial condition or an exposure event.
  # Changed: Exposure at birth now modeled as initial status
  
  # Red Blood Cells
  d/dt(RBC) = PLASMA * kx - 
    k16 * RBC;                                                              
  
  # Metallothionein
  d/dt(META) = UPTAKE_MT + 
    k14 * LIVER + 
    k16 * RBC - 
    k_MT_out * k17x * META -  # NEW added k_MT_out for unit consistency
    k_MT_out * k17b * META;   # NEW added k_MT_out for unit consistency                    
  
  # total blood amount
  # Changed - erased /vb and added blood burden
  BLOOD = (RBC + k20 * (PLASMA + META));                                                         
  BLOOD_burden = (RBC + k20 * (PLASMA + META))/vb; 
  
  # Liver
  d/dt(LIVER) = k12 * PLASMA - 
    (k13 + k14 + k15) * LIVER;                                       
  
  # Kidney
  d/dt(KIDNEY) = k_MT_out * k17x * META - # NEW added k_MT_out for unit consistency
    k18 *KIDNEY - 
    k19x * KIDNEY;                                          
  
  kidney_burden = (KIDNEY)/vk;                                                           
  
  # Other tissues
  d/dt(OTHER) = k9 * PLASMA - 
    k10 * OTHER;                                                        
  
  #wb = BLOOD + LIVER + KIDNEY + OTHER + LUNG + GUT;                                                # body burden is actually total
  
  # Cumulative Feces- Changed
  d/dt(FECES) = (1-k5)*kabs*GUT +     # NEW: added kabs for unit consistency
    k11*PLASMA + 
    k15*LIVER ;  
  
  # Daily feces output
  # d/dt(FECES) = (1-k5)*GUT + k11*PLASMA + k15*LIVER - FECES;                                        
  
  # Cumulative Urine - Changed, added k_MT_out for unit consistency
  d/dt(URINE) = k_MT_out * k17b * META + 
    KIDNEY * k19x; 
 
  # daily urine excretion
  # d/dt(URINE) = META * k17b + KIDNEY * k19x - URINE;                                              
  
  # Urinary Cd excretion rate
  ur = k_MT_out * k17b * META + KIDNEY * k19x;                               # NEW added k_MT_out for unit consistency
  Conc_urine_cd = ur / Vurine;
  ucdcr = ur/ucr; 
  
  # cumulative Cd exhalation
  d/dt(EXH) = (1 - k1_dust - k2_dust) * f_inh_available * AIR_inhal_ing * VInhalation + 
    (1 - k1_cig  - k2_cig)  * f_inh_available * kinh_release * CIG_inhal_ing;         
  
 # d/dt(EXH) =
 #  (1 - k1_dust - k2_dust) * f_inh_available * kinh_release * AIR_inhal_ing * VInhalation + (1 - k1_cig  - k2_cig)  * f_inh_available * kinh_release * CIG_inhal_ing - EXH;    # DAILY output Exhalaltion
  
  # Total Body Burden
  total = GUT + INTESTINE + LUNG + RBC + META + LIVER + KIDNEY + OTHER + PLASMA; #+TOTAL_UPTAKE- took out ;           # Total Body burden
  
  # Total Cd excretion
  Excreted = FECES + URINE + EXH;
  
})
