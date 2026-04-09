PBK1 <- rxode2({ 
  year=time/365 ;
  
  # 1/ Body weight ----
  
  # NEW ITEM: Delta body weight. Before age 3, linear decline. 
  # The reference value is an in input.
  
  if(time <= 1095){Delta_BW = 1 + (Delta_BWs3 - 1) * (time / 1095)}
  if(time > 1095){Delta_BW =  Delta_BWs3}
  
  
  # BW en kg
  # NEW ITEM: After age 79, the equation no longer holds, 
  # so we use the value at age 79.
  
  mval = year * 12
  
  if (sex == 1) {
    if (year <= 79) {
      m2 = mval * mval;
      m3 = m2 * mval;
      m4 = m3 * mval;
      m5 = m4 * mval;
      m6 = m5 * mval;
      m7 = m6 * mval;
      m8 = m7 * mval;
      m9 = m8 * mval;
      m10 = m9 * mval;
      m11 = m10 * mval;
      
      wbw = (3.938425 + 0.7518199 * mval - 0.02023793 * m2 + 0.0002921682 * m3
             - 2.06762e-06 * m4 + 8.469e-09 * m5 - 2.188427e-11 * m6
             + 3.699776e-14 * m7 - 4.099077e-17 * m8 + 2.874804e-20 * m9
             - 1.159732e-23 * m10 + 2.052602e-27 * m11) * Delta_BW;
    } else {
      wbw = 76 * Delta_BW;
    }
  } else if (sex == 2) {
    if (year <= 79) {
      m2 = mval * mval;
      m3 = m2 * mval;
      m4 = m3 * mval;
      m5 = m4 * mval;
      m6 = m5 * mval;
      m7 = m6 * mval;
      m8 = m7 * mval;
      m9 = m8 * mval;
      m10 = m9 * mval;
      m11 = m10 * mval;
      
      wbw = (3.932403 + 0.6866462 * mval - 0.01949911 * m2 + 0.00031311 * m3
             - 2.466654e-06 * m4 + 1.113217e-08 * m5 - 3.131402e-11 * m6
             + 5.693737e-14 * m7 - 6.706947e-17 * m8 + 4.947858e-20 * m9
             - 2.079251e-23 * m10 + 3.800367e-27 * m11) * Delta_BW;
    } else {
      wbw = 68 * Delta_BW;
    }
  }
  
  
  # 2/ Hematocrite ----
  
  # NEW ITEM: The if/ifelse conditional in the version provided by 
  # Thomas was incorrect. Rewritten.
  
  y2 = year * year;
  y3 = y2 * year;
  y4 = y3 * year;
  y5 = y4 * year;
  y6 = y5 * year;
  
  if (year <= 2) {
    hct = 0.359;
  } else if (year < 18) {
    hct = 1.12815e-06 * y3 - 1.72362e-04 * y2 + 8.15264e-03 * year + 0.327363;
  } else {
    hct = 0.4248446;
  }
  
  
  # 3/ Fat ----
  
  # NEW ITEM: Treatment after age 79.
  # NEW ITEM: No more Delta organ.
  
  y2 = year * year;
  wbw2 = wbw * wbw;
  
  if (sex == 1 && year <= 79) {
    vfat = 1.3054356 + 0.3622685 * year - 0.0025165 * y2
    + 0.0906119 * wbw + 0.0001731 * wbw2;
  }
  else if (sex == 1 && year > 79) {
    vfat = 14.21917 + 0.0906119 * wbw + 0.0001731 * wbw2;
  }
  else if (sex == 2 && year <= 79) {
    vfat = 0.6132 + 0.08475 * year + 8.151e-05 * y2
    + 0.1341 * wbw + 0.002297 * wbw2;
  }
  else if (sex == 2 && year > 79) {
    vfat = 7.817154 + 0.1341 * wbw + 0.002297 * wbw2;
  }
  
  
  # 4/ Brain ----
  
  # NEW ITEM: Treatment after age 79.
  # NEW ITEM: No more Delta organ.
  
  
  if (sex == 1 && year <= 79) {
    vbr = 1.45 + (0.350 - 1.45) * exp(-0.440 * year);
  }
  else if (sex == 1 && year > 79) {
    vbr = 1.45;
  }
  else if (sex == 2 && year <= 79) {
    vbr = 1.30 + (0.347 - 1.30) * exp(-0.573 * year);
  }
  else if (sex == 2 && year > 79) {
    vbr = 1.3;
  }
  
  # 5/ Kidney ----
  
  # NEW ITEM: Treatment after age 79.
  # NEW ITEM: No more Delta organ.
  
  if (sex == 1 && year <= 79) {
    vk = (0.0042 + (0.00767 - 0.0042) * exp(-0.206 * year)) * wbw;
  } else if (sex == 1 && year > 79) {
    vk = (0.0042 + 2.969074e-10) * wbw;
  } else if (sex == 2 && year <= 79) {
    vk = (0.0046 + (0.00709 - 0.0046) * exp(-0.221 * year)) * wbw;
  } else if (sex == 2 && year > 79) {
    vk = (0.0046 + 6.514063e-11) * wbw;
  }
  
  
  # 6/ Hair ----
  
  vhair = 0.002*wbw;
  
  # 7/ Liver ----
  
  # NEW ITEM: Treatment after age 79.
  # NEW ITEM: No more Delta organ.  
  
  
  if (sex == 1 && year <= 79) {
    vl = (0.0247 + (0.0409 - 0.0247) * exp(-0.218 * year)) * wbw;
  } else if (sex == 1 && year > 79) {
    vl = (0.0247 + 5.371498e-10) * wbw;
  } else if (sex == 2 && year <= 79) {
    vl = (0.0233 + (0.038 - 0.0233) * exp(-0.122 * year)) * wbw;
  } else if (sex == 2 && year > 79) {
    vl = (0.0233 + 9.58489e-07) * wbw;
  }
  
  # 8/ Blood ----
  
  # NEW ITEM: Check your equation in SBML; there might be a division error.
  
  if (sex == 1) {
    if (year < 1) {
      vb <- (-0.027 * year + 0.077) * wbw
    } else {
      vb <- (0.0761 / (1 + exp(-0.683 * year + 0.946))) * wbw 
    }
  } else {
    if (year < 1) {
      vb <- (-0.0273 * year + 0.0771) * wbw
    } else if (year < 14.019723) {
      vb <- (3.28e-05 * y3 - 1.21e-03 * y2 + 1.24e-02 * year + 3.86e-02) * wbw
    } else {
      vb <- 0.065 * wbw
    }
  }
  
  # 9/ Plasma ----
  
  vp = (1 - hct) * vb;
  
  # 10/ Red blood cells ----
  
  vrbc = hct * vb;
  
  
  # 11/ Blood, plasma, RBC volume at birth ----
  
  # NEW ITEM: For prenatal exposure. I believe it can be done outside pbk?
  
  if (sex == 1) {
    wbw0 = 3.938425 * Delta_BW;
  } else {
    wbw0 = 3.932403 * Delta_BW;
  }
  vb0 = 0.0771 * wbw0;
  vp0 = (1 - hct) * vb0;
  vrbc0 = hct * vb0
  # Hyp: Cs = Cp = Crbc
  
  
  # 12/ Heart ----
  
  # NEW ITEM: No more Delta organ.
  
  
  if (sex == 1) {
    vheart <- 0.0045 * wbw
  } else {
    vheart <- 0.004167 * wbw
  }
  
  # 13/ Muscles ----
  
  # NEW ITEM: Treatment after age 79.
  # NEW ITEM: No more Delta organ.
  
  term_poly = (-0.0001264 * y2 + 0.006131 * year + 0.926);
  
  if (sex == 1) {
    if (year < 24.3) {
      vm = (0.3973 + (0.201 - 0.3973) * exp(-0.141 * year)) * wbw;
    } else if (year <= 79) {
      vm = (0.3973 + (0.201 - 0.3973) * exp(-0.141 * year)) * term_poly * wbw;
    } else {
      vm = 0.2469149 * wbw;
    }
  } else if (sex == 2) {
    if (year <= 25.90709) {
      vm = (0.2917 + (0.207 - 0.2917) * exp(-0.339 * year)) * wbw;
    } else if (year <= 79) {
      vm = (0.2917 + (0.207 - 0.2917) * exp(-0.339 * year)) * term_poly * wbw;
    } else {
      vm = 0.1812876 * wbw;
    }
  }
  
  # 14/ Diaphragm ----
  
  vd = (3e-04) * wbw;
  
  
  # 15/ Skin ----
  
  # NEW ITEM: No more Delta organ.
  
  if (sex == 1) {
    if (year < 20) {
      vs = (-1.171e-05 * y3 + 5.413e-04 * y2 - 6.1966e-03 * year + 4.623e-02) * wbw;
    } else {
      vs = 0.0452 * wbw;
    }
  } else {
    if (year < 20) {
      vs = (-7.8882e-06 * y3 + 4.0224e-04 * y2 - 5.2146e-03 * year + 4.5605e-02) * wbw;
    } else {
      vs = 0.0383 * wbw;
    }
  }
  
  # 16/ Total bone mineral content (TBBMC) ----
  
  # NEW ITEM: Treatment after age 79.
  # NEW ITEM: No more Delta organ.
  
  TBBMC = 0;
  
  if (sex == 1) {
    if (year < 50) {
      TBBMC = 0.89983 + ((2.9901 - 0.89989) / (1 + exp((14.17081 - year) / 1.58179)));
    } else if (year <= 79) {
      TBBMC = 0.89983 + ((2.9901 - 0.89989) / (1 + exp((14.17081 - year) / 1.58179))) - 0.0019 * year;
    } else {  
      TBBMC = 2.83994;
    }
  } else if (sex == 2) {
    if (year < 50) {
      TBBMC = 0.89983 + ((2.9901 - 0.89989) / (1 + exp((14.17081 - year) / 1.58179)));
    } else if (year <= 79) {
      TBBMC = 0.74042 + ((2.14976 - 0.74042) / (1 + exp((12.35466 - year) / 1.35750))) - 0.0056 * year;
    } else { 
      TBBMC = 1.70736;
    }
  }
  
  # 17/ Bone volume ----
  
  
  if (sex == 1) {
    vbone = TBBMC / 0.65 / 0.5;
  } else if (sex == 2) {
    vbone = 1;
  }
  
  
  # 18/ Bone Marrow ----
  
  # NEW ITEM: No more Delta organ.
  
  if (sex == 1) {
    vmarr = (0.05 + (0.0138 - 0.05) * exp(-0.112 * year)) * wbw;
  } else {
    vmarr = (0.045 + (0.0138 - 0.045) * exp(-0.136 * year)) * wbw;
  }
  
  # 19/ Richly perfused tissue ----
  
  if (sex == 1) {
    vbreast = (3.42e-4 * (1 / (1 + exp(-1.42 * year + 20.1)))) * wbw;
  } else {
    vbreast = (0.00833 * (1 / (1 + exp(-1.92 * year + 28.6)))) * wbw;
  }
  
  
  if (sex == 1) {
    vthyr <- 0.000274 * wbw
  } else {
    vthyr <- 0.0002833 * wbw
  }
  
  # NEW ITEM: No more Delta organ.
  
  if (sex == 1) {
    vspleen <- 0.0021 * wbw
  } else {
    vspleen <- 0.0022 * wbw
  }
  
  # NEW ITEM: No more Delta organ.
  
  if (sex == 1) {
    vpancreas <- 0.00192 * wbw
  } else {
    vpancreas <- 0.002 * wbw
  }
  
  
  vadrenal = 0.0002 + (0.00171 - 0.0002) * exp(-2.02 * year);
  
  
  
  # 20/ Gonads ----
  
  # NEW ITEM: No more Delta organ.
  # NEW ITEM: The if/ifelse conditional in the version provided by 
  # Thomas was incorrect. Rewritten.
  
  if (sex == 1) {
    if (year < 20.1) {
      vgonads = (-1.516e-07 * y3 + 9.3351e-06 * y2 - 1.1177e-04 * year + 4.7966e-04) * wbw;
    } else {
      vgonads = 0.0008 * wbw;
    }
  } else {
    if (year < 1) {
      vgonads = (-1.064e-03 * year + 1.338e-03) * wbw;
    } else if (year < 20) {
      vgonads = (2.6380e-07 * y3 - 1.7943e-06 * y2 - 5.6465e-06 * year + 2.8105e-04) * wbw;
    } else {
      vgonads = 0.001552 * wbw;
    }
  }
  
  
  # 21/ Lungs ----
  
  # NEW ITEM: No more Delta organ.
  
  if(sex == 1){vlungs = 0.0068 * wbw;}
  else{vlungs = 0.0070 * wbw;}
  
  
  # 22/ Volume rich ----
  
  vrich = vbreast + vthyr + vspleen + vpancreas + vadrenal + vgonads + vlungs;
  
  
  # 23/ Gut ----
  
  # NEW ITEM: No more Delta organ.
  
  if(sex == 1){vstomach = 0.0021 * wbw;}
  else{vstomach = 0.0023 * wbw;}
  
  
  
  # 24/ Intestinal tract ----
  
  # NEW ITEM: No more Delta organ.
  
  if (sex == 1) {
    if (year < 16) {
      vintestine = (-8.2562e-05 * y2 + 1.3523e-03 * year + 1.293e-02) * wbw;
    } else {
      vintestine = 0.014 * wbw;
    }
  } else {
    if (year < 14.453301) {
      vintestine = (-7.421e-05 * y2 + 1.276e-03 * year + 1.298e-02) * wbw;
    } else {
      vintestine = 0.0160 * wbw;
    }
  }
  
  
  # 25/ Total bodyweight ----
  
  wbw_f = vfat + vbr + vk + vhair + vb + vl + vheart + vd + vm + vs + vbone + vmarr + vstomach + vintestine + vbreast + vthyr + vspleen + vpancreas + vadrenal + vgonads + vlungs;
  
  
  # 26/ k19x, k17x, k17b ----
  
  # NEW ITEM: I suggest we make this distinction outside of the PBK.
  # k5 = sex*k5_h + (1-sex)*k5_f;
  # if(sex == 1){k5 = k5_h;}
  # else{k5 = k5_f;}
  
  
  if (year <= 30) {
    k19x = k19;
    k17x = k17;
  } else{
    k19x = k19 + k21 * (year - 30);
    k17x = max(k17 - (k17 / 3) * (year - 30) / 50, 0);
  }
  
  k17b = 1 - k17x;
  
  
  # 27/ ucr ----
  
  ucr= (0.032+2.098e-02*year+9.104e-03*y2-4.550e-04*y3+7.578e-06*y4-4.232e-08*y5)*Delta_creat;
  if (year>70) {ucr=0.865756*Delta_creat;}
  
  
  # 28/ Volume tidal, FqBreath, vds ----
  
  
  #Inhalation
  #Volume of tidal
  Vtidal = 0;
  if(sex == 1){
    if(year < 21){Vtidal = 0.0337 * year + 0.0407;}
    else{Vtidal = 0.75;}}
  else{Vtidal = 0.46 + (0.0392 - 0.46) * exp(-0.127 * year);}
  
  FqBreath = 12 + (38.9 - 12) * exp(-0.176 * year); # Breath frequency by day
  
  #Volume of death space in lungs
  if(sex == 1){
    if(year <= 18.4){vds = 0.0076 * year + 0.0101;}
    else{vds = 0.15;}}
  else{vds = 0.12 + (0.0107-0.12) * exp(-0.0986 * year);}
  
  VInhalation = FqBreath * (Vtidal - vds) * 60 * 24; # Volume of inhalation by day
  
  
  
  
  # Dose of Cd by smoking exposures
  
  # NEW ITEM: I suggest to look into this outside of PBK. It's part of the 
  # exposure scenario.
  
  # if(year > age_deb && year < age_fin){Cig = nb_cig * kcig * smoke_cd;}
  # else {Cig = 0;}
  # << CB
  
  
  
  
  
  
  # ODE ----
  
  d/dt(DIET_ing) = - DIET_ing ; # Dietary exposure (µg/kg)
  d/dt(AIR_inhal_ing) = -AIR_inhal_ing; # Exposure by inhalation (µg/L)
  d/dt(AIR_derm) = - AIR_derm; # NEW ITEM
  d/dt(CIG_inhal_ing) = - CIG_inhal_ing; # NEW ITEM
  d/dt(SOIL_ing) = - SOIL_ing; # Exposure by soil (µg)
  d/dt(DUST_ing) = - DUST_ing; # Exposure by dust (µg)
  d/dt(DUST_derm) = - DUST_derm; # NEW ITEM
  d/dt(COSM_ing) = - COSM_ing; # NEW ITEM (µg)
  d/dt(COSM_derm) = - COSM_derm; # NEW ITEM
  d/dt(CORD_quant) = - CORD_quant; # NEW ITEM
  
  
  d/dt(LUNG) = k2_dust*(AIR_inhal_ing * VInhalation) + k2_cig * CIG_inhal_ing - LUNG*(k3 + k4);                                      # pulmonary region at t=T
  
  # NEW item: COSM ing.
  d/dt(GUT) = k5 * (DIET_ing* wbw_f + SOIL_ing + COSM_ing + DUST_ing + k1_cig * CIG_inhal_ing + k1_dust * (AIR_inhal_ing * VInhalation) + k4 * LUNG) - k6 * GUT;  # GI-tract
  
  
  UPTAKE2=k8;
  if ((k7*UPTAKE1) <= k8) {UPTAKE2=k7*UPTAKE1;} # UPTAKE2 flow to blood pool has a maximum = k8
  UPTAKE3 = UPTAKE1 - UPTAKE2; # UPTAKE3 goes to metallothionein (b3)
  d/dt(UPTAKE1) =  k3*LUNG + k6*GUT - UPTAKE2 - UPTAKE3; # uptake pool
  
  # NEW ITEM: DERMAL absorption.
  # NEW ITEM: Exposure at birth. This can likely be implemented differently, 
  # depending on whether it is viewed as an initial condition or an exposure event.
  d/dt(PLASMA) = UPTAKE3 + k10 * OTHER + k13 * LIVER - k9*PLASMA - k11 * PLASMA - kx * PLASMA + 0.5/100*AIR_derm + 0.5/100*DUST_derm + 0.5/100*COSM_derm + CORD_quant*vp0;                   # Plasma
  
  # NEW ITEM: Exposure at birth. This can likely be implemented differently, 
  # depending on whether it is viewed as an initial condition or an exposure event.
  d/dt(RBC) = PLASMA * kx - k16 * RBC + CORD_quant*vrbc0;                                           # Red Blood Cells
  
  d/dt(META) = UPTAKE2 + k14 * LIVER + k16 * RBC - k17 * META - k17b * META;                        # Metallothionein
  
  BLOOD = (RBC + k20 * (PLASMA + META))/vb;                                                            # total blood
  
  d/dt(LIVER) = k12 * PLASMA - (k13 + k14 + k15) * LIVER;                                                        # Liver
  
  d/dt(KIDNEY) = k17x*META - k18 *KIDNEY - k19x * KIDNEY;                                                        # Kidney
  
  kidney_burden = (KIDNEY)/vk;                                                                         # kidney burden in ug/kg
  
  d/dt(OTHER) = k9 * PLASMA - k10 * OTHER;                                                                       # other tissues
  
  wb = BLOOD + LIVER + KIDNEY + OTHER + LUNG + GUT;                                                # body burden
  
  d/dt(FECES) = k11*PLASMA + k15*LIVER;                                                                          # feces
  
  d/dt(URINE) = META * k17b + KIDNEY * k19x;                                                                     # urine cumulative
  
  ur = META * k17b + KIDNEY * k19x;          # Dose of Cd in urine (in ug)
  # spot urine Cd creatinine normalized (ug Cd/g Cr)
  Vurine = 0.0294 * wbw_f;
  
  Conc_urine_cd = ur / Vurine;
  
  ucdcr = ur/ucr; 

})
