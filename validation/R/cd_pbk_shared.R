PBK <- rxode2({ 
  
  year=time/365.25 ; 

  # 1/ Body weight ----
  
  # NEW ITEM: Delta body weight. Before age 3, linear decline. 
  # The reference value is an input parameter and its calculation was described in the WG.
  
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
  
  # NEW ITEM: Check your equation in SBML; there might be a division error and a degree error.

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
  
  
  
  # 29/ ODEs ----
  
  # NEW ITEM. Please note that in my version, I have separated the calculations 
  # by source and route. We decided not to do this in SBML, so please do not 
  # take this into account.
  # Moving on, there are still one or two changes proposals to note, 
  # all marked as ‘NEW ITEM’.
  
  
  
  # ODE
  
  # >> CB : proposition de découplage des ODEs pour avoir les contributions
  # des sources-voies. Je me suis permis quelques réécritures des variables
  # pour faire apparaitre les couples sources-voies (pour la food c'est évident 
  # qu'il s'agit d'ingestion, mais pour être systématique, j'ai précisé).
  # Proposition d'ajouter un facteur pour que la dose en fin de journée soit
  # nulle (0.01% de l'initiale restant) -log(0.0001,exp(1))/1.
  
  
  # Diet-ingestion virtual compartment
  d/dt(DIET_ing) = - DIET_ing;    # Dietary exposure (µg)
  # Virtual compartment of the dose in µg of cadmium to be delivered 
  # to the gut throughout the day (exponential decay), coming from diet.
  
  # Air for inhalation and ingestion virtual compartment
  d/dt(AIR_inhal_ing) = -AIR_inhal_ing;  
  # Virtual compartment of the dose in µg of cadmium to be delivered then to 
  # to lung and gut throughout the day (exponential decay), coming from air.
  
  # Air-dermal virtual compartment
  d/dt(AIR_derm) = - AIR_derm;
  # Virtual compartment of the dose in µg of cadmium to be delivered 
  # to the skin throughout the day (exponential decay), coming from air.
  
  # Cigarette for inhalation and ingestion virtual compartment
  d/dt(CIG_inhal_ing) = - CIG_inhal_ing;
  # Virtual compartment of the dose in µg of cadmium to be delivered 
  # to  throughout the day (exponential decay), 
  # coming from cigarettes.
  
  # Soil-ingestion virtual compartment
  d/dt(SOIL_ing) = - SOIL_ing;
  # Virtual compartment of the dose in µg of cadmium to be delivered 
  # to the gut throughout the day (exponential decay), coming from soil. 
  # Contain k1_cig, performed outside PBK.
  
  # Dust-ingestion virtual compartment
  d/dt(DUST_ing) = - DUST_ing;
  # Virtual compartment of the dose in µg of cadmium to be delivered 
  # to the gut throughout the day (exponential decay), coming from dust.
  
  # Dust-dermal virtual compartment
  d/dt(DUST_derm) = - DUST_derm;
  # Virtual compartment of the dose in µg of cadmium to be delivered 
  # to the skin throughout the day (exponential decay), coming from dust.
  
  # Cosmetics-ingestion virtual compartment
  d/dt(COSM_ing) = - COSM_ing;
  # Virtual compartment of the dose in µg of cadmium to be delivered 
  # to the gut throughout the day (exponential decay), coming from cosmetics.
  
  # Cosmetics-dermal virtual compartment
  d/dt(COSM_derm) = - COSM_derm;
  # Virtual compartment of the dose in µg of cadmium to be delivered 
  # to the skin throughout the day (exponential decay), coming from cosmetics.
  
  
  # Cord blood. Plus rien à partir de 10 minutes. -log(0.0001,exp(1))/(10/(60x24))
  d/dt(CORD_quant) = - CORD_quant;
  
  
  # 1. LUNG ODEs
  
  # Original
  # d/dt(LUNG) =  k2_dust*(AIR * VInhalation) + k2_cig * Cig - LUNG*(k3 + k4); # pulmonary region at t=T
  
  # New
  
  d/dt(LUNG_AIR_inhal) = k2_dust * VInhalation * AIR_inhal_ing - LUNG_AIR_inhal*(k3 + k4);
  d/dt(LUNG_CIG_inhal) = k2_cig * CIG_inhal_ing - LUNG_CIG_inhal*(k3 + k4);
  
  
  
  # 2. GUT ODEs
  
  # Original
  # d/dt(GUT) = k5 * (DIET * wbw_f + SOIL + DUST + k1_cig * Cig + k1_dust * (AIR * VInhalation) + k4 * LUNG) - k6 * GUT;  # GI-tract
  
  # New
  d/dt(GUT_AIR_inhal) = k5 * k4 * LUNG_AIR_inhal - k6 * GUT_AIR_inhal;
  d/dt(GUT_AIR_ing) = k5 * k1_dust * VInhalation * AIR_inhal_ing - k6 * GUT_AIR_ing;
  d/dt(GUT_CIG_inhal) = k5 * k4 * LUNG_CIG_inhal - k6 * GUT_CIG_inhal;
  d/dt(GUT_CIG_ing) = k5 * k1_cig * CIG_inhal_ing - k6 * GUT_CIG_ing;
  d/dt(GUT_DIET_ing) = k5 * DIET_ing - k6 * GUT_DIET_ing;
  d/dt(GUT_SOIL_ing) = k5 * SOIL_ing - k6 * GUT_SOIL_ing;
  d/dt(GUT_DUST_ing) = k5 * DUST_ing - k6 * GUT_DUST_ing;
  d/dt(GUT_COSM_ing) = k5 * COSM_ing - k6 * GUT_COSM_ing;
  
  
  # 3. UPTAKE1 ODEs
  
  # UPTAKE3 = UPTAKE1 - UPTAKE2;
  
  # Original
  # Rk: UPTAKE3 = UPTAKE1 - UPTAKE2
  # So the equation :
  # d/dt(UPTAKE1) =  k3*LUNG + k6*GUT - UPTAKE2 - UPTAKE3; # uptake pool
  # can be rewritten :
  # d/dt(UPTAKE1) =  k3*LUNG + k6*GUT - UPTAKE2 - UPTAKE3; 
  # d/dt(UPTAKE1) =  k3*LUNG + k6*GUT - UPTAKE1
  
  # New
  d/dt(UPTAKE1_AIR_inhal) = k3*LUNG_AIR_inhal + k6*GUT_AIR_inhal - UPTAKE1_AIR_inhal;
  d/dt(UPTAKE1_AIR_ing) = k6*GUT_AIR_ing - UPTAKE1_AIR_ing;
  d/dt(UPTAKE1_CIG_inhal) = k3*LUNG_CIG_inhal + k6*GUT_CIG_inhal - UPTAKE1_CIG_inhal;
  d/dt(UPTAKE1_CIG_ing) =  k6*GUT_CIG_ing - UPTAKE1_CIG_ing;
  d/dt(UPTAKE1_DIET_ing) = k6*GUT_DIET_ing - UPTAKE1_DIET_ing;
  d/dt(UPTAKE1_SOIL_ing) = k6*GUT_SOIL_ing - UPTAKE1_SOIL_ing;
  d/dt(UPTAKE1_DUST_ing) = k6*GUT_DUST_ing - UPTAKE1_DUST_ing;
  d/dt(UPTAKE1_COSM_ing) = k6*GUT_COSM_ing - UPTAKE1_COSM_ing;
  
  
  # 4. PLASMA ODEs
  
  # Original
  # d/dt(PLASMA) = UPTAKE3 + k10 * OTHER + k13 * LIVER - k9*PLASMA - k11 * PLASMA - kx * PLASMA;
  # Rewritten using UPTAKE3 = UPTAKE1 - UPTAKE2;
  # d/dt(PLASMA) = UPTAKE1 - UPTAKE2 + k10 * OTHER + k13 * LIVER - k9*PLASMA - k11 * PLASMA - kx * PLASMA;
  
  # The following equation also slighly rewritten
  # UPTAKE2=k8;
  # if ((k7*UPTAKE1) <= k8) {UPTAKE2=k7*UPTAKE1;}
  
  # New (including dermal absorption)
  
  
  
  UPTAKE1 = UPTAKE1_AIR_inhal + UPTAKE1_AIR_ing + UPTAKE1_CIG_inhal + 
    UPTAKE1_CIG_ing + UPTAKE1_DIET_ing + UPTAKE1_SOIL_ing + 
    UPTAKE1_DUST_ing + UPTAKE1_COSM_ing;
  
  
  UPTAKE2_AIR_inhal = k8*UPTAKE1_AIR_inhal/UPTAKE1;
  UPTAKE2_AIR_ing = k8*UPTAKE1_AIR_ing/UPTAKE1;
  UPTAKE2_CIG_inhal = k8*UPTAKE1_CIG_inhal/UPTAKE1;
  UPTAKE2_CIG_ing = k8*UPTAKE1_CIG_ing/UPTAKE1;
  UPTAKE2_DIET_ing = k8*UPTAKE1_DIET_ing/UPTAKE1;
  UPTAKE2_SOIL_ing = k8*UPTAKE1_SOIL_ing/UPTAKE1;
  UPTAKE2_DUST_ing = k8*UPTAKE1_DUST_ing/UPTAKE1;
  UPTAKE2_COSM_ing = k8*UPTAKE1_COSM_ing/UPTAKE1;
  
  
  if ((k7*UPTAKE1) <= k8){
    UPTAKE2_AIR_inhal = k7*UPTAKE1_AIR_inhal;
    UPTAKE2_AIR_ing = k7*UPTAKE1_AIR_ing;
    UPTAKE2_CIG_inhal = k7*UPTAKE1_CIG_inhal;
    UPTAKE2_CIG_ing = k7*UPTAKE1_CIG_ing;
    UPTAKE2_DIET_ing = k7*UPTAKE1_DIET_ing;
    UPTAKE2_SOIL_ing = k7*UPTAKE1_SOIL_ing;
    UPTAKE2_DUST_ing = k7*UPTAKE1_DUST_ing;
    UPTAKE2_COSM_ing = k7*UPTAKE1_COSM_ing;
  }
  
  
  d/dt(PLASMA_AIR_inhal) = UPTAKE1_AIR_inhal - UPTAKE2_AIR_inhal + k10 * OTHER_AIR_inhal + k13 * LIVER_AIR_inhal - (k9+k11+kx)*PLASMA_AIR_inhal;
  d/dt(PLASMA_AIR_ing) = UPTAKE1_AIR_ing - UPTAKE2_AIR_ing + k10 * OTHER_AIR_ing + k13 * LIVER_AIR_ing - (k9+k11+kx)*PLASMA_AIR_ing;
  d/dt(PLASMA_CIG_inhal) = UPTAKE1_CIG_inhal - UPTAKE2_CIG_inhal + k10 * OTHER_CIG_inhal + k13 * LIVER_CIG_inhal - (k9+k11+kx)*PLASMA_CIG_inhal;
  d/dt(PLASMA_CIG_ing) = UPTAKE1_CIG_ing - UPTAKE2_CIG_ing + k10 * OTHER_CIG_ing + k13 * LIVER_CIG_ing - (k9+k11+kx)*PLASMA_CIG_ing;
  d/dt(PLASMA_DIET_ing) = UPTAKE1_DIET_ing - UPTAKE2_DIET_ing + k10 * OTHER_DIET_ing + k13 * LIVER_DIET_ing - (k9+k11+kx)*PLASMA_DIET_ing;
  d/dt(PLASMA_SOIL_ing) = UPTAKE1_SOIL_ing - UPTAKE2_SOIL_ing + k10 * OTHER_SOIL_ing + k13 * LIVER_SOIL_ing - (k9+k11+kx)*PLASMA_SOIL_ing;
  d/dt(PLASMA_DUST_ing) = UPTAKE1_DUST_ing - UPTAKE2_DUST_ing + k10 * OTHER_DUST_ing + k13 * LIVER_DUST_ing - (k9+k11+kx)*PLASMA_DUST_ing;
  d/dt(PLASMA_COSM_ing) = UPTAKE1_COSM_ing - UPTAKE2_COSM_ing + k10 * OTHER_COSM_ing + k13 * LIVER_COSM_ing - (k9+k11+kx)*PLASMA_COSM_ing;
  
  # NEW ITEM: DERMAL absorption.
  d/dt(PLASMA_AIR_derm) = k10 * OTHER_AIR_derm + k13 * LIVER_AIR_derm + 0.5/100*AIR_derm - (k9+k11+kx)*PLASMA_AIR_derm;
  d/dt(PLASMA_DUST_derm) = k10 * OTHER_DUST_derm + k13 * LIVER_DUST_derm + 0.5/100*DUST_derm - (k9+k11+kx)*PLASMA_DUST_derm;
  d/dt(PLASMA_COSM_derm) = k10 * OTHER_COSM_derm + k13 * LIVER_COSM_derm + 0.5/100*COSM_derm - (k9+k11+kx)*PLASMA_COSM_derm;
  # NEW ITEM: Exposure at birth. This can likely be implemented differently, 
  # depending on whether it is viewed as an initial condition or an exposure event.
  d/dt(PLASMA_CORD_quant) = k10 * OTHER_CORD_quant + k13 * LIVER_CORD_quant + CORD_quant*vp0 - (k9+k11+kx)*PLASMA_CORD_quant;
  
  
  # 5. RBC ODEs
  
  # Original
  # d/dt(RBC) = PLASMA * kx - k16 * RBC; # Red Blood Cells
  
  # New
  d/dt(RBC_AIR_inhal) = PLASMA_AIR_inhal * kx - k16 * RBC_AIR_inhal;
  d/dt(RBC_AIR_ing) = PLASMA_AIR_ing * kx - k16 * RBC_AIR_ing;
  d/dt(RBC_CIG_inhal) = PLASMA_CIG_inhal * kx - k16 * RBC_CIG_inhal;
  d/dt(RBC_CIG_ing) = PLASMA_CIG_ing * kx - k16 * RBC_CIG_ing;
  d/dt(RBC_DIET_ing) = PLASMA_DIET_ing * kx - k16 * RBC_DIET_ing;
  d/dt(RBC_SOIL_ing) = PLASMA_SOIL_ing * kx - k16 * RBC_SOIL_ing;
  d/dt(RBC_DUST_ing) = PLASMA_DUST_ing * kx - k16 * RBC_DUST_ing;
  d/dt(RBC_COSM_ing) = PLASMA_COSM_ing * kx - k16 * RBC_COSM_ing;
  d/dt(RBC_AIR_derm) = PLASMA_AIR_derm * kx - k16 * RBC_AIR_derm;
  d/dt(RBC_DUST_derm) = PLASMA_DUST_derm * kx - k16 * RBC_DUST_derm;
  d/dt(RBC_COSM_derm) = PLASMA_COSM_derm * kx - k16 * RBC_COSM_derm;
  
  # NEW ITEM: Exposure at birth. This can likely be implemented differently, 
  # depending on whether it is viewed as an initial condition or an exposure event.
  d/dt(RBC_CORD_quant) = PLASMA_CORD_quant * kx + CORD_quant*vrbc0 - k16 * RBC_CORD_quant;
  
  
  # 6. META ODEs
  
  # Original
  # d/dt(META) = UPTAKE2 + k14 * LIVER + k16 * RBC - k17 * META - k17b * META;
  
  # New
  d/dt(META_AIR_inhal) = UPTAKE2_AIR_inhal + k14 * LIVER_AIR_inhal + k16 * RBC_AIR_inhal - (k17+k17b) * META_AIR_inhal;
  d/dt(META_AIR_ing) = UPTAKE2_AIR_ing + k14 * LIVER_AIR_ing + k16 * RBC_AIR_ing - (k17+k17b) * META_AIR_ing;
  d/dt(META_CIG_inhal) = UPTAKE2_CIG_inhal + k14 * LIVER_CIG_inhal + k16 * RBC_CIG_inhal - (k17+k17b) * META_CIG_inhal;
  d/dt(META_CIG_ing) = UPTAKE2_CIG_ing + k14 * LIVER_CIG_ing + k16 * RBC_CIG_ing - (k17+k17b) * META_CIG_ing;
  d/dt(META_DIET_ing) = UPTAKE2_DIET_ing + k14 * LIVER_DIET_ing + k16 * RBC_DIET_ing - (k17+k17b) * META_DIET_ing;
  d/dt(META_SOIL_ing) = UPTAKE2_SOIL_ing + k14 * LIVER_SOIL_ing + k16 * RBC_SOIL_ing - (k17+k17b) * META_SOIL_ing;
  d/dt(META_DUST_ing) = UPTAKE2_DUST_ing + k14 * LIVER_DUST_ing + k16 * RBC_DUST_ing - (k17+k17b) * META_DUST_ing;
  d/dt(META_COSM_ing) = UPTAKE2_COSM_ing + k14 * LIVER_COSM_ing + k16 * RBC_COSM_ing - (k17 + k17b) * META_COSM_ing;
  d/dt(META_AIR_derm) = k14 * LIVER_AIR_derm + k16 * RBC_AIR_derm - (k17 + k17b) * META_AIR_derm;
  d/dt(META_DUST_derm) = k14 * LIVER_DUST_derm + k16 * RBC_DUST_derm - (k17 + k17b) * META_DUST_derm;
  d/dt(META_COSM_derm) = k14 * LIVER_COSM_derm + k16 * RBC_COSM_derm - (k17 + k17b) * META_COSM_derm;
  d/dt(META_CORD_quant) = k14 * LIVER_CORD_quant + k16 * RBC_CORD_quant - (k17 + k17b) * META_CORD_quant;
  
  
  
  # 7. BLOOD equation
  
  # Original
  # BLOOD = (RBC + k20 * (PLASMA + META))/vb; # total blood
  
  # New (not decoupled, because blood not used in the urine output)
  RBC = RBC_AIR_inhal + RBC_AIR_ing + RBC_CIG_inhal + RBC_CIG_ing + 
    RBC_DIET_ing + RBC_SOIL_ing + RBC_DUST_ing +  RBC_COSM_ing + 
    RBC_AIR_derm + RBC_DUST_derm + RBC_COSM_derm + RBC_CORD_quant;
  
  
  PLASMA = PLASMA_AIR_inhal + PLASMA_AIR_ing + PLASMA_CIG_inhal +
    PLASMA_CIG_ing + PLASMA_DIET_ing + PLASMA_SOIL_ing + 
    PLASMA_DUST_ing + PLASMA_COSM_ing + PLASMA_AIR_derm + 
    PLASMA_DUST_derm + PLASMA_COSM_derm + PLASMA_CORD_quant;
  
  META = META_AIR_inhal + META_AIR_ing + META_CIG_inhal + META_CIG_ing + 
    META_DIET_ing + META_SOIL_ing + META_DUST_ing + META_COSM_ing + 
    META_AIR_derm + META_DUST_derm + META_COSM_derm + META_CORD_quant;
  
  BLOOD = (RBC + k20 * (PLASMA + META))/vb; # total blood
  
  
  # 8. LIVER ODEs
  
  # Original
  # d/dt(LIVER) = k12 * PLASMA - (k13 + k14 + k15) * LIVER;
  
  # New
  d/dt(LIVER_AIR_inhal) = k12 * PLASMA_AIR_inhal - (k13 + k14 + k15) * LIVER_AIR_inhal;
  d/dt(LIVER_AIR_ing) = k12 * PLASMA_AIR_ing - (k13 + k14 + k15) * LIVER_AIR_ing;
  d/dt(LIVER_AIR_derm) = k12 * PLASMA_AIR_derm - (k13 + k14 + k15) * LIVER_AIR_derm;
  d/dt(LIVER_CIG_inhal) = k12 * PLASMA_CIG_inhal - (k13 + k14 + k15) * LIVER_CIG_inhal;
  d/dt(LIVER_CIG_ing) = k12 * PLASMA_CIG_ing - (k13 + k14 + k15) * LIVER_CIG_ing;
  d/dt(LIVER_DIET_ing) = k12 * PLASMA_DIET_ing - (k13 + k14 + k15) * LIVER_DIET_ing;
  d/dt(LIVER_SOIL_ing) = k12 * PLASMA_SOIL_ing - (k13 + k14 + k15) * LIVER_SOIL_ing;
  d/dt(LIVER_DUST_ing) = k12 * PLASMA_DUST_ing - (k13 + k14 + k15) * LIVER_DUST_ing;
  d/dt(LIVER_DUST_derm) = k12 * PLASMA_DUST_derm - (k13 + k14 + k15) * LIVER_DUST_derm;
  d/dt(LIVER_COSM_ing) = k12 * PLASMA_COSM_ing - (k13 + k14 + k15) * LIVER_COSM_ing;
  d/dt(LIVER_COSM_derm) = k12 * PLASMA_COSM_derm - (k13 + k14 + k15) * LIVER_COSM_derm;
  d/dt(LIVER_CORD_quant) = k12 * PLASMA_CORD_quant - (k13 + k14 + k15) * LIVER_CORD_quant;
  
  
  # 9. KIDNEY ODEs
  
  # Original
  # d/dt(KIDNEY) = k17x*META - k18 * KIDNEY - k19x * KIDNEY; # Kidney
  
  # New
  
  d/dt(KIDNEY_AIR_inhal) = k17x*META_AIR_inhal - (k18+k19x) * KIDNEY_AIR_inhal;
  d/dt(KIDNEY_AIR_ing) = k17x*META_AIR_ing - (k18+k19x) * KIDNEY_AIR_ing;
  d/dt(KIDNEY_AIR_derm) = k17x*META_AIR_derm - (k18+k19x) * KIDNEY_AIR_derm;
  d/dt(KIDNEY_CIG_inhal) = k17x*META_CIG_inhal - (k18+k19x) * KIDNEY_CIG_inhal;
  d/dt(KIDNEY_CIG_ing) = k17x*META_CIG_ing - (k18+k19x) * KIDNEY_CIG_ing;
  d/dt(KIDNEY_DIET_ing) = k17x*META_DIET_ing - (k18+k19x) * KIDNEY_DIET_ing;
  d/dt(KIDNEY_SOIL_ing) = k17x*META_SOIL_ing - (k18+k19x) * KIDNEY_SOIL_ing;
  d/dt(KIDNEY_DUST_ing) = k17x*META_DUST_ing - (k18+k19x) * KIDNEY_DUST_ing;
  d/dt(KIDNEY_DUST_derm) = k17x*META_DUST_derm - (k18+k19x) * KIDNEY_DUST_derm;
  d/dt(KIDNEY_COSM_ing) = k17x*META_COSM_ing - (k18+k19x) * KIDNEY_COSM_ing;
  d/dt(KIDNEY_COSM_derm) = k17x*META_COSM_derm - (k18+k19x) * KIDNEY_COSM_derm;
  d/dt(KIDNEY_CORD_quant) = k17x*META_CORD_quant - (k18+k19x) * KIDNEY_CORD_quant;
  
  
  KIDNEY <- KIDNEY_AIR_inhal + KIDNEY_AIR_ing + KIDNEY_CIG_inhal + 
    KIDNEY_AIR_derm + KIDNEY_CIG_ing + KIDNEY_DIET_ing + 
    KIDNEY_SOIL_ing + KIDNEY_DUST_ing  + KIDNEY_DUST_derm +
    KIDNEY_COSM_ing + KIDNEY_COSM_derm + KIDNEY_CORD_quant;
  
  kidney_burden = (KIDNEY)/vk; # kidney burden in ug/kg
  
  
  # 10. OTHER ODEs
  
  # Original
  # d/dt(OTHER) = k9 * PLASMA - k10 * OTHER; # other tissues
  
  # New
  d/dt(OTHER_AIR_inhal) = k9 * PLASMA_AIR_inhal - k10 * OTHER_AIR_inhal;
  d/dt(OTHER_AIR_ing) = k9 * PLASMA_AIR_ing - k10 * OTHER_AIR_ing;
  d/dt(OTHER_AIR_derm) = k9 * PLASMA_AIR_derm - k10 * OTHER_AIR_derm;
  d/dt(OTHER_CIG_inhal) = k9 * PLASMA_CIG_inhal - k10 * OTHER_CIG_inhal;
  d/dt(OTHER_CIG_ing) = k9 * PLASMA_CIG_ing - k10 * OTHER_CIG_ing;
  d/dt(OTHER_DIET_ing) = k9 * PLASMA_DIET_ing - k10 * OTHER_DIET_ing;
  d/dt(OTHER_SOIL_ing) = k9 * PLASMA_SOIL_ing - k10 * OTHER_SOIL_ing;
  d/dt(OTHER_DUST_ing) = k9 * PLASMA_DUST_ing - k10 * OTHER_DUST_ing;
  d/dt(OTHER_DUST_derm) = k9 * PLASMA_DUST_derm - k10 * OTHER_DUST_derm;
  d/dt(OTHER_COSM_ing) = k9 * PLASMA_COSM_ing - k10 * OTHER_COSM_ing;
  d/dt(OTHER_COSM_derm) = k9 * PLASMA_COSM_derm - k10 * OTHER_COSM_derm;
  d/dt(OTHER_CORD_quant) = k9 * PLASMA_CORD_quant - k10 * OTHER_CORD_quant;
  
  # 11. Body burden
  
  # Original
  # wb = BLOOD + LIVER + KIDNEY + OTHER + LUNG + GUT; # body burden
  
  # New (for the moment, no need to have it by source-root)
  LIVER = LIVER_AIR_inhal + LIVER_AIR_ing + LIVER_AIR_derm + 
    LIVER_CIG_inhal  + LIVER_CIG_ing + LIVER_DIET_ing + 
    LIVER_SOIL_ing + LIVER_DUST_ing + LIVER_DUST_derm +
    LIVER_COSM_ing + LIVER_COSM_derm  + LIVER_CORD_quant;
  
  OTHER = OTHER_AIR_inhal + OTHER_AIR_ing + OTHER_AIR_derm + 
    OTHER_CIG_inhal + OTHER_CIG_ing + OTHER_DIET_ing + 
    OTHER_SOIL_ing + OTHER_DUST_ing  + OTHER_DUST_derm +
    OTHER_COSM_ing + OTHER_COSM_derm + OTHER_CORD_quant;
  
  LUNG = LUNG_AIR_inhal + LUNG_CIG_inhal;
  
  GUT = GUT_AIR_inhal + GUT_AIR_ing + GUT_CIG_inhal + 
    GUT_CIG_ing + GUT_DIET_ing + GUT_SOIL_ing + 
    GUT_DUST_ing + GUT_COSM_ing;
  
  wb = BLOOD + LIVER + KIDNEY + OTHER + LUNG + GUT; # body burden
  
  
  # 12. FECES ODEs
  # Pas de découplage pour le moment.
  
  d/dt(FECES) = k11*PLASMA + k15*LIVER; # feces
  
  
  # 13. URINE ODEs
  
  # Original
  # d/dt(URINE) = META * k17b + KIDNEY * k19x; # urine cumulative
  
  # New
  d/dt(URINE_AIR_inhal) = META_AIR_inhal * k17b + KIDNEY_AIR_inhal * k19x;
  d/dt(URINE_AIR_ing) = META_AIR_ing * k17b + KIDNEY_AIR_ing * k19x;
  d/dt(URINE_AIR_derm) = META_AIR_derm * k17b + KIDNEY_AIR_derm * k19x;
  d/dt(URINE_CIG_inhal) = META_CIG_inhal * k17b + KIDNEY_CIG_inhal * k19x;
  d/dt(URINE_CIG_ing) = META_CIG_ing * k17b + KIDNEY_CIG_ing * k19x;
  d/dt(URINE_DIET_ing) = META_DIET_ing * k17b + KIDNEY_DIET_ing * k19x;
  d/dt(URINE_SOIL_ing) = META_SOIL_ing * k17b + KIDNEY_SOIL_ing * k19x;
  d/dt(URINE_DUST_ing) = META_DUST_ing * k17b + KIDNEY_DUST_ing * k19x;
  d/dt(URINE_DUST_derm) = META_DUST_derm * k17b + KIDNEY_DUST_derm * k19x;
  d/dt(URINE_COSM_ing) = META_COSM_ing * k17b + KIDNEY_COSM_ing * k19x;
  d/dt(URINE_COSM_derm) = META_COSM_derm * k17b + KIDNEY_COSM_derm * k19x;
  d/dt(URINE_CORD_quant) = META_CORD_quant * k17b + KIDNEY_CORD_quant * k19x;
  
  
  # 12. Urine equation
  
  # Original
  # ur = META * k17b + KIDNEY * k19x;  # Dose of Cd in urine (in ug)
  
  # New
  ur_AIR_inhal = META_AIR_inhal * k17b + KIDNEY_AIR_inhal * k19x;
  ur_AIR_ing = META_AIR_ing * k17b + KIDNEY_AIR_ing * k19x;
  ur_AIR_derm = META_AIR_derm * k17b + KIDNEY_AIR_derm * k19x;
  ur_CIG_inhal = META_CIG_inhal * k17b + KIDNEY_CIG_inhal * k19x;
  ur_CIG_ing = META_CIG_ing * k17b + KIDNEY_CIG_ing * k19x;
  ur_DIET_ing = META_DIET_ing * k17b + KIDNEY_DIET_ing * k19x;
  ur_SOIL_ing = META_SOIL_ing * k17b + KIDNEY_SOIL_ing * k19x;
  ur_DUST_ing = META_DUST_ing * k17b + KIDNEY_DUST_ing * k19x;
  ur_DUST_derm = META_DUST_derm * k17b + KIDNEY_DUST_derm * k19x;
  ur_COSM_ing = META_COSM_ing * k17b + KIDNEY_COSM_ing * k19x;
  ur_COSM_derm = META_COSM_derm * k17b + KIDNEY_COSM_derm * k19x;
  ur_CORD_quant = META_CORD_quant * k17b + KIDNEY_CORD_quant * k19x;
  
  ur = ur_AIR_inhal + ur_AIR_ing + ur_AIR_derm + 
    ur_CIG_inhal + ur_CIG_ing + ur_DIET_ing + 
    ur_SOIL_ing + ur_DUST_ing  + ur_DUST_derm +
    ur_COSM_ing + ur_COSM_derm +  ur_CORD_quant;
  
  Vurine = 0.0294 * wbw_f;
  Conc_urine_cd = ur / Vurine;
  
  
  # 13. Main output
  
  # Original
  # ucdcr = ur/ucr;   # spot urine Cd creatinine normalized (ug Cd/g Cr)
  
  # New
  ucdcr = ur/ucr; # sum of the following
  
  ucdcr_AIR_inhal = ur_AIR_inhal / ucr;
  ucdcr_AIR_ing = ur_AIR_ing / ucr;
  ucdcr_AIR_derm = ur_AIR_derm / ucr;
  ucdcr_CIG_inhal = ur_CIG_inhal / ucr;
  ucdcr_CIG_ing = ur_CIG_ing / ucr;
  ucdcr_DIET_ing = ur_DIET_ing / ucr;
  ucdcr_SOIL_ing = ur_SOIL_ing / ucr;
  ucdcr_DUST_ing = ur_DUST_ing / ucr;
  ucdcr_DUST_derm = ur_DUST_derm / ucr;
  ucdcr_COSM_ing = ur_COSM_ing / ucr;
  ucdcr_COSM_derm = ur_COSM_derm / ucr;
  ucdcr_CORD_quant = ur_CORD_quant / ucr;
  
})