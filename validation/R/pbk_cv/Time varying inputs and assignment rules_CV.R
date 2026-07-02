
# Changes in volumes / time-varying inputs

phys <- function(time, sex, Delta_BWs3, Delta_creat,
                 k5_h, k5_f, k17, k19, k21) {
  
  year <- time / 365
  
  y2 = year * year
  y3 = y2 * year
  y4 = y3 * year
  y5 = y4 * year
  y6 = y5 * year
  
  mval <- year * 12
  # 1/ Body weight ----
  # NEW ITEM: Delta body weight. Before age 3, linear decline. 
  # The reference value is an in input.
  
  if (time <= 1095) {
    Delta_BW <- 1 + (Delta_BWs3 - 1) * (time / 1095)
  } else {
    Delta_BW <- Delta_BWs3
  }
  
  # BW en kg
  # NEW ITEM: After age 79, the equation no longer holds, 
  # so we use the value at age 79.
  
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
  
  
  if (year <= 2) {
    hct = 0.359;
  } else if (year < 18) {
    hct = 1.12815e-06 * y3 - 1.72362e-04 * y2 + 8.15264e-03 * year + 0.327363;
  } else {
    hct = 0.4248446;
  }
  
  # 3/ Blood ----
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
  
  # 4/ Plasma ----
  vp = (1 - hct) * vb;
  
  # 5/ Red blood cells ----
  vrbc = hct * vb;
  
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
  
  # 6/ Lungs ----
  # NEW ITEM: No more Delta organ.
  
  if(sex == 1){vlungs = 0.0068 * wbw;}
  else{vlungs = 0.0070 * wbw;}
  
  # 7/ Intestinal tract ----
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
  
  # 8/ Liver ----
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
  
  # 9/ Volume tidal, FqBreath, vds ----
  #Inhalation
  #Volume of tidal
  Vtidal = 0;
  if(sex == 1){
    if(year < 21){Vtidal = 0.0337 * year + 0.0407;}
    else{Vtidal = 0.75;}}
  else{Vtidal = 0.46 + (0.0392 - 0.46) * exp(-0.127 * year);}
  
  FqBreath = 12 + (38.9 - 12) * exp(-0.176 * year); # Breath frequency by min
  
  #Volume of death space in lungs
  if(sex == 1){
    if(year <= 18.4){vds = 0.0076 * year + 0.0101;}
    else{vds = 0.15;}}
  else{vds = 0.12 + (0.0107-0.12) * exp(-0.0986 * year);}
  
  VInhalation = FqBreath * (Vtidal - vds) * 60 * 24; # Volume of inhalation by day; L/day
  
  # 10/ ucr ----
  
  ucr <- (
    0.032 +
      2.098e-02*year +
      9.104e-03*year^2 -
      4.550e-04*year^3 +
      7.578e-06*year^4 -
      4.232e-08*year^5
  ) * Delta_creat
  
  if (year > 70) {
    ucr <- 0.865756 * Delta_creat
  }
  

  
  # 11/ k5, k19x, k17x, k17b ----
  
  # NEW ITEM: I suggest we make this distinction outside of the PBK.
  if (sex == 1) {
    k5 <- k5_h
  } else {
    k5 <- k5_f
  }
  
  if (year <= 30) {
    k19x = k19;
    k17x = k17;
  } else{
    k19x = k19 + k21 * (year - 30);
    k17x = max(k17 - (k17 / 3) * (year - 30) / 50, 0);
  }
  
  k17b = 1 - k17x;
  # Is given: 1 = kx + k9 + k11 + k12 
  
  # 12/ Total bodyweight and rest
  # 12/ Rest of body / other tissues ----
  vother <- wbw - (vk + vb + vl + vintestine + vlungs)
  
  if (vother < 0) {
    stop("vother is negative. Check organ volume equations.")
  }
  
  wbw_f =  vk + vb + vl  + vintestine + vlungs + vother;
  
  # 13/ spot urine Cd creatinine normalized (ug Cd/g Cr)
  Vurine = 0.0294 * wbw_f;
  
  # 14/ initial volumes for blood
  # hct0 is now used
  if (sex == 1) {
    wbw0 <- 3.938425 * Delta_BW
  } else {
    wbw0 <- 3.932403 * Delta_BW
  }
  
  hct0 <- 0.359
  vb0 <- 0.0771 * wbw0
  vp0 <- (1 - hct0) * vb0
  vrbc0 <- hct0 * vb0
  
  
  return(list(
    year = year,
    wbw = wbw,
    wbw_f = wbw_f,
    wbw0 = wbw0,
    vb = vb,
    vp = vp,
    vrbc = vrbc,
    vb0 = vb0,
    vp0= vp0,
    vrbc0 = vrbc0,
    vk = vk,
    vintestine = vintestine,
    vlungs = vlungs,
    Vtidal = Vtidal,
    vds = vds,
    vother = vother,
    VInhalation = VInhalation,
    vl = vl,
    k5 = k5,
    k17x = k17x,
    k19x = k19x,
    k17b = k17b,
    Vurine = Vurine,
    ucr = ucr
  ))
}




