$PARAM

BIRTH   = 1900  // Year of birth

SEXBABY  = 1    // Sex of individual (0 = Female, 1 = Male)

Delta_BW = 1    // Variability of bodyweight

Delta_HT = 1    // Variability of height     

Delta_creat = 1 // Variability of creatinine excretion

// Variability for male
	Delta_Brain_M = 1
	Delta_Kidney_M = 1
	Delta_Liver_M = 1
	Delta_Pancreas_M = 1
	Delta_Stomach_M = 1
	Delta_Small_Intestine_M = 1
	Delta_Large_Intestine_M = 1
	Delta_Heart_M = 1
	Delta_Bone_M = 1
	Delta_Gonad_M = 1
	Delta_Lung_M = 1
	Delta_Spleen_M = 1
	Delta_Muscle_M = 1
	Delta_Adipose_M = 1

// Variability for female
	Delta_Brain_F = 1
	Delta_Kidney_F = 1
	Delta_Liver_F = 1
	Delta_Pancreas_F = 1
	Delta_Stomach_F = 1
	Delta_Small_Intestine_F = 1
	Delta_Large_Intestine_F = 1
	Delta_Heart_F = 1
	Delta_Bone_F = 1
	Delta_Gonad_F = 1
	Delta_Lung_F = 1
	Delta_Spleen_F = 1
	Delta_Muscle_F = 1
	Delta_Adipose_F = 1

//Rate Constants and biokinetic variables
      /// Rate and toxicokinetic values (empircal value from Kjellström et Nordberg, 1978; Béchaux et al. 2014)
      k1_cig  = 0.1        // Fraction of inhalation intake deposited in NP and TB regions from smoking
      k1_dust = 0.7        // Fraction of inhalation intake deposited in NP and TB regions from dust
      k2_cig  = 0.4        // Fraction of inhalation intake deposited in pulmonary region from smoking
      k2_dust = 0.13       // Fraction of inhalation intake deposited in pulmonary region from dust
      k3      = 0.05       // Rate of transfer of inhalation intake to uptake pool (/day) 
      k4      = 0.005      // Rate of trasfer of air cadmium -> tractus GI (/day)
      k5_h    = 0.05       // Fraction of GI-tract cadmium retained in epithelium for male
      k5_f    = 0.10       // Fraction of GI-tract cadmium retained in epithelium for female
      k6      = 0.05       // Rate of transfer of cadmium in the GI-tract to uptake pool (/day)
      k7      = 0.25       // Fraction of free cadmium in blood
      k8      = 1          // Maximum mass of cadmium in uptake pool/metallothionein (microgram)
      k9      = 0.44       // Rate of transfer from blood pool B1 to other tissues
      k10     = 0.00014    // Rate of transfer of cadmium in other tissues to blood pool B1 (/day)
      k11     = 0.27       // Rate of transfer of cadmium in blood pool B1 to feces
      k12     = 0.25       // Rate of transfer of cadmium in blood pool B1 to liver
      k13     = 0.00003    // Rate of transfer of cadmium in liver to blood pool B1 (/day)
      k14     = 0.00016    // Rate of transfer of cadmium in liver to blood pool B3 (/day)
      k15     = 0.00005    // Rate of transfer of cadmium in liver to feces (/day)
      k16     = 0.012      // Rate of transfer of cadmium in blood pool B2 to blood pool B3 (/day) 
      k17     = 0.95       // Rate of transfer of cadmium in blood pool B3 to kidney
      k18     = 0.00001    // Rate of transfer of cadmium in kidney to blood pool B1 (/day)
      k19     = 0.00014    // Age-specific rate constant for transfer of cadmium in kidney to urine (/day)
      k20     = 0.1        // Fraction of cadmium in blood pools B1 + B2 that contribute to cadmium in blood pool B4
      k21     = 0.0000011  // Increased transfer of cadmium from kidney to urine after age 30 (/day)
      kx      = 0.04       // Rate of transfer of cadmium in B1 to blood B2


// Smoking status
age_deb = 18.6    // Beginning of smoking 
age_fin = 38.2    // End of smoking
smoke_cd = 1      // ug/ per cigaret
kcig = 0.1        // Rate ingestion of cadmium in a cigaret
nb_cig = 15       // Consumption of cigarets by day

$MAIN

// Evolution of age with integrations
double year = TIME/365;

// Poids corporel (kg) 
double wbw = 3.0;
double ht = 3.0;
  if(SEXBABY == 1){
  	wbw = (3.938425 + 0.7518199*year*12 - 0.02023793*pow(year*12,2) + 0.0002921682*pow(year*12,3) - 2.06762e-06*pow(year*12,4) + 8.469e-09*pow(year*12,5) - 2.188427e-11*pow(year*12,6) + 3.699776e-14*pow(year*12,7) - 4.099077e-17*pow(year*12,8) + 2.874804e-20*pow(year*12,9) - 1.159732e-23*pow(year*12,10) + 2.052602e-27*pow(year*12,11))*Delta_BW;
  	ht = (53.14237 + 2.299147*year*12 - 0.04567729*pow(year*12,2) + 0.0005784706*pow(year*12,3) - 4.082151e-06*pow(year*12,4) + 1.729718e-08*pow(year*12,5) - 4.667123e-11*pow(year*12,6) + 8.238663e-14*pow(year*12,7) - 9.495884e-17*pow(year*12,8) + 6.892621e-20*pow(year*12,9) - 2.861566e-23*pow(year*12,10) + 5.182964e-27*pow(year*12,11))*Delta_HT;
  }
  else{
  	wbw = (3.932403 + 0.6866462*year*12 - 0.01949911*pow(year*12,2) + 0.00031311*pow(year*12,3) - 2.466654e-06*pow(year*12,4) + 1.113217e-08*pow(year*12,5) - 3.131402e-11*pow(year*12,6) + 5.693737e-14*pow(year*12,7) - 6.706947e-17*pow(year*12,8) + 4.947858e-20*pow(year*12,9) - 2.079251e-23*pow(year*12,10) + 3.800367e-27*pow(year*12,11))*Delta_BW;
  	ht = (54.7663 + 1.901851*year*12 - 0.03451895*pow(year*12,2) + 0.0004589584*pow(year*12,3) - 3.466838e-06*pow(year*12,4) + 1.557048e-08*pow(year*12,5) - 4.400249e-11*pow(year*12,6) + 8.052606e-14*pow(year*12,7) - 9.542125e-17*pow(year*12,8) + 7.073083e-20*pow(year*12,9) - 2.982651e-23*pow(year*12,10) + 5.463555e-27*pow(year*12,11))*Delta_HT;
  }

  // Body Mass Index over lifetime (in kg/m^2)
  double BMI = wbw/pow((ht/100),2);
	
  // Hematocrit (proportion of RBC in blood)
    //Mallick et al. (2020) or Pendse et al. (2020)
  double hct = 0;
    if(year <= 2){hct = 0.359;}
    if(year > 2 && year < 18){hct = 1.12815e-06 * pow(year,3) - 1.72362e-04 * pow(year,2) + 8.15264e-03 * year + 0.327363;}
    if (year >= 18) {hct = 1.12815e-06 * pow(18,3) - 1.72362e-04 * pow(18,2) + 8.15264e-03 * 18 + 0.327363;}
        
  // Surface area (in m) Can be used in the calculation of other organs, not directly used in the model
    // Mallick et al. (2020) or Pendse et al. (2020) or Price P.S. et al. (2003)
  double Sskin = exp(-3.75 + 0.42*log(ht) + 0.52*log(wbw));

//// Volume of organs
  
  // Fat (non essential adipose tissues) (in L)
    // Deepika et al. (2021)
    double vfat = 0;
        if(SEXBABY == 1){vfat = (1.3054356 + 0.3622685 * year - 0.0025165 * pow(year,2) + 0.0906119 * wbw + 0.0001731 * pow(wbw,2)) * Delta_Adipose_M;}
        else{vfat = (6.132e-01 + 8.475e-02 * year + 8.151e-05 * pow(year,2) + 1.341e-01 * wbw + 2.297e-03 * pow(wbw,2)) * Delta_Adipose_F;}
    
  // Brain (in L)
    // Beaudouin et al. 2010
    double vbr = 0;
        if(SEXBABY == 1){vbr = (1.45 + (0.350 - 1.45) * exp(-0.440 * year)) * Delta_Brain_M;}
        else{vbr = (1.30 + (0.347 - 1.30)*exp(-0.573 * year)) * Delta_Brain_F;}
      
  // Kidneys
    // Beaudouin et al. 2010
    double vk = 0;
        if(SEXBABY == 1){vk = (0.0042+(0.00767 - 0.0042) * exp(-0.206 * year)) * wbw * Delta_Kidney_M;}
        else{vk = (0.0046 + (0.00709 - 0.0046) * exp(-0.221 * year)) * wbw * Delta_Kidney_F;}
      
  // Hair
  double vhair = 0.002*wbw;
  
  // Liver
    // Beaudouin et al. 2010
    double vl = 0;
        if(SEXBABY == 1){vl = (0.0247 + (0.0409 - 0.0247) * exp(-0.218 * year)) * wbw * Delta_Liver_M;}
        else{vl = (0.0233 + (0.038 - 0.0233) * exp(-0.122 * year)) * wbw * Delta_Liver_F;}
    
  /// BLOOD (composition = (1-HCT)% plasma + HCT% RBC)(in L)
    // Beaudouin et al. (2010)
    double vb = 0;
        if(SEXBABY == 1){
            if(year < 1){vb = (-0.027 * pow(year,1) + 0.077) * wbw;}
            else{vb = (0.0761 * 1/(1 + exp(-0.683 * year + 0.946))) * wbw;}
        }
        else{
            if(year < 1){vb = (-0.0273 * pow(year,1) + 0.0771) * wbw;}
            if(year >=1 && year < 14.019723){vb = (3.28e-05 * pow(year,3) - 1.21e-03 * pow(year,2) + 1.24e-02 * year + 3.86e-02) * wbw;}
            if(year >= 14.019723){vb = 0.065 * wbw;}
        }
    double vp = (1-hct)*vb;
    double vrbc = hct*vb;
    
  // Slowly perfused tissue (Heart, Diaphragm, muscles, skin, bones)
    // Beaudouin et al. 2010
    double vheart = 0;
        if(SEXBABY == 1){vheart = 0.0045 * wbw * Delta_Heart_M;}
        else{vheart = 0.004167 * wbw * Delta_Heart_F;}

  /// Muscles
    // Beaudouin et al. 2010
    double vm = 0;
        if(SEXBABY == 1){
            if(year < 24.3){vm = (0.3973 + (0.201 - 0.3973) * exp(-0.141 * year)) * wbw * Delta_Muscle_M;}
            else{vm = (0.3973 + (0.201 - 0.3973) * exp(-0.141 * year)) * (-0.0001264 * pow(year,2) + 0.006131 * year + 0.926) * wbw * Delta_Muscle_M;}
        }
        else{
            if(year <= 25.90709){vm = (0.2917 + (0.207 - 0.2917) * exp(-0.339 * year))* wbw * Delta_Muscle_F;}
            else{vm = (0.2917 + (0.207 - 0.2917) * exp(-0.339 * year)) * (-0.0001264 * pow(year,2) + 0.006131 * year + 0.926) * wbw * Delta_Muscle_F;}
        }

  /// Diaphragm
  double vd = (3e-04)*wbw;
  
  /// Skin
    // Beaudouin et al. (2010)
    double vs = 0;
        if(SEXBABY == 1){
            if(year < 20){vs = (-1.171e-05 * pow(year,3) + 5.413e-04 * pow(year,2) -  6.1966e-03 * year + 4.623e-02) * wbw;}
            else{vs = 0.0452 * wbw;}
        }
        else{
            if(year < 20){vs = (-7.8882e-06 * pow(year,3) + 4.0224e-04 * pow(year,2) - 5.2146e-03 * year + 4.5605e-02) * wbw;}
            else{vs = 0.0383 * wbw;}
        }

  /// Skeleton (Marrow / Bones = 80 % Cortical + 20% Trabecular)
    // Pearce et al. (2017) - Httk
	// Total Body Bone Mineral Content
  double TBBMC = 0;
    if(SEXBABY == 1){
      if(year < 50){TBBMC = 0.89983 + ((2.9901 - 0.89989)/(1 + 1 * exp((14.17081 - year)/1.58179)));}
      else{TBBMC =  0.89983 + ((2.9901-0.89989)/(1+1*exp((14.17081 - year)/1.58179))) - (0.0019*year);}
    }
    else{
      if(year < 50){TBBMC = 0.89983 + ((2.9901 - 0.89989)/(1 + 1 * exp((14.17081 - year)/1.58179)));}
      else{TBBMC = 0.74042 + ((2.14976 - 0.74042)/(1 + 1 * exp((12.35466 - year)/1.35750))) - (0.0056 * year);}
    }

    double vbone = (TBBMC/0.65)/0.5 * Delta_Bone_M * SEXBABY + (1 - SEXBABY) * Delta_Bone_F;
    
  /// Bone marrow (71 % Red Marrow + 29% Yellow Marrow)
    // Beaudouin et al. (2010)
    double vmarr = 0;
      if(SEXBABY == 1){vmarr = (0.05 + (0.0138 - 0.05) * exp(-0.112 * year)) * wbw;}
      else{vmarr = (0.045 + (0.0138 - 0.045)*exp(-0.136 * year)) * wbw;}
    
  // Richly perfused tissue (Breast + Thyroid + Spleen + Pancreas + Adrenals + Gonads + Lungs)
  
    // Breast (Beaudouin et al. (2010))
    double vbreast = 1;
      if(SEXBABY == 1){vbreast = (3.42e-4 * (1 / (1 + exp(-1.42 * year + 20.1)))) * wbw;}
      else{vbreast = (0.00833 * 1/(1 + exp(-1.92 * year + 28.6))) * wbw;}
    
    // Thyroid
      // Beaudouin et al. (2010)
      double vthyr = 0;
        if(SEXBABY == 1){vthyr = 0.000274 * wbw;}
        else{vthyr = 0.0002833 * wbw;}
  
    // Spleen
      // Beaudouin et al. (2010)
      double vspleen = 0;
        if(SEXBABY == 1){vspleen = 0.0021 * wbw * Delta_Spleen_M;}
        else{vspleen = 0.0022 * wbw * Delta_Spleen_F;}

    // Pancreas
      // Beaudouin et al. (2010)
      double vpancreas = 0;
        if(SEXBABY == 1){vpancreas = 0.00192 * wbw * Delta_Pancreas_M;}
        else{vpancreas = 0.002 * wbw * Delta_Pancreas_F;}

    // Adrenals (Beaudouin et al. (2010))
    double vadrenal = 0;
        if(SEXBABY == 1){vadrenal = (2.0e-04 + (1.71e-03 - 2.0e-04) * exp(-2.02 * year)) * wbw;}
        else{vadrenal = (0.0002 + (0.00171 - 0.0002) * exp(-2.02 * year)) * wbw;}
    
    // Gonads / Reproductive organs
      // Beaudouin et al. (2010)
      double vgonads = 0;
        if(SEXBABY == 1){
          if(year < 20.1){vgonads = (-1.516e-07 * pow(year,3) + 9.3351e-06 * pow(year,2) - 1.1177e-04 * year + 4.7966e-04) * wbw * Delta_Gonad_M;}
          else{vgonads = 0.0008 * wbw * Delta_Gonad_M;}
        }
        else{
          if(year < 1){vgonads = (-1.064e-03*year + 1.338e-03)* wbw * Delta_Gonad_F;}
          if(year >= 1 && year < 20){vgonads = (2.6380e-07 * pow(year,3) - 1.7943e-06 * pow(year,2) - 5.6465e-06 * year + 2.8105e-04) * wbw * Delta_Gonad_F;}
          if(year >= 20){vgonads = 0.001552 * wbw * Delta_Gonad_F;}
        }
       
    // Lungs
      // Beaudouin et al. (2010)
      double vlungs = 0;
        if(SEXBABY == 1){vlungs = 0.0068 * wbw * Delta_Lung_M;}
        else{vlungs = 0.0070 * wbw * Delta_Lung_F;}
      
  double vrich = vbreast + vthyr + vspleen + vpancreas + vadrenal + vgonads + vlungs;


  /// Gut (Stomach + Small intestine + Large intestine)
    // Stomach
      // Beaudouin et al. (2010)
      double vstomach = 0;
        if(SEXBABY == 1){vstomach = 0.0021 * wbw * Delta_Stomach_M;}
        else{vstomach = 0.0023 * wbw * Delta_Stomach_F;}
 
    // Intestinal tract (Small + Large Intestine)
      // Beaudouin et al. (2010)
      double vintestine = 0;
      double Delta_Intestine = SEXBABY * (0.63 * Delta_Small_Intestine_M + 0.37 * Delta_Large_Intestine_M) + (1 - SEXBABY) * (0.63 * Delta_Small_Intestine_F + 0.37 * Delta_Large_Intestine_F);
        if(SEXBABY == 1){
          if(year < 16){vintestine = (-8.2562e-05*pow(year,2) + 1.3523e-03*year + 1.293e-02) * wbw * Delta_Intestine;}
          else{vintestine = 0.014 * wbw * Delta_Intestine;}
        }
        else{
          if(year < 14.453301){vintestine = (-7.421e-05*pow(year,2) + 1.276e-03*year + 1.298e-02) * wbw * Delta_Intestine;}
          else{vintestine = 0.0160 * wbw * Delta_Intestine;}
        }

    // Calculation of the total bodyweight
    double wbw_f = vfat + vbr + vk + vhair + vb + vl + vheart + vd + vm + vs + vbone + vmarr + vstomach + vintestine + vbreast + vthyr + vspleen + vpancreas + vadrenal + vgonads + vlungs;


//// modification de k5 en fonction du sexe
double k5 = SEXBABY*k5_h + (1-SEXBABY)*k5_f;
  if(SEXBABY == 1){k5 = k5_h;}
  else{k5 = k5_f;}

//// modification de k19 et k17 en fonction de l age
double k19x=k19;		
double k17x = k17;
  if (year > 30)
    {k19x = k19 + k21*(year-30); 
    k17x = k17 -(k17/3)*(year-30)/50;}  

double k17b = 1 - k17x;

//creatinine en fonction de l age (C.B?chaux) !!! Ne convient pas apr?s 70 ans !!!
double ucr= (0.032+2.098e-02*year+9.104e-03*pow(year,2)-4.550e-04*pow(year,3)+7.578e-06*pow(year,4)-4.232e-08*pow(year,5))*Delta_creat;
  if (year>70) {ucr=(0.032+2.098e-02*70+9.104e-03*pow(70,2)-4.550e-04*pow(70,3)+7.578e-06*pow(70,4)-4.232e-08*pow(70,5))*Delta_creat;}

double UPTAKE2=k8;
  if ((k7*UPTAKE1) <= k8) {UPTAKE2=k7*UPTAKE1;}   // UPTAKE2 goes to metallothionein (b3) flow to blood pool has a maximum = k8

double UPTAKE3 = UPTAKE1 - UPTAKE2;               // UPTAKE3 flow to blood pool

double ur = META * k17b + KIDNEY * k19x;          // Dose of Cd in urine (in ug)

double ucdcr = ur/ucr;                              // spot urine Cd creatinine normalized (ug Cd/g Cr)

double Vurine = 0.0294 * wbw_f;

double Conc_urine_cd = ur / Vurine;

/// Inhalation
  // Volume of tidal
  double Vtidal = 0;
    if(SEXBABY == 1){
      if(year < 21){Vtidal = 0.0337 * year + 0.0407;}
      else{Vtidal = 0.75;}}
    else{Vtidal = 0.46 + (0.0392 - 0.46) * exp(-0.127 * year);}
	
	double FqBreath = 12 + (38.9 - 12) * exp(-0.176 * year); // Breath frequency by day

  // Volume of death space in lungs
  double vds = 0;
    if(SEXBABY == 1){
      if(year <= 18.4){vds = 0.0076 * year + 0.0101;}
      else{vds = 0.15;}}
    else{vds = 0.12 + (0.0107-0.12) * exp(-0.0986 * year);}

	double VInhalation = FqBreath * (Vtidal - vds) * 60 * 24; // Volume of inhalation by day

  // Dose of Cd by smoking exposures
  double Cig = 0;
    if(year > age_deb && year < age_fin){Cig = nb_cig * kcig * smoke_cd;}
    else {Cig = 0;}

$ODE

////  Calculate state variables based on Kjellstrom and Nordberg, (1978) 
//// units of the state variables are ug Cd

dxdt_DIET = - DIET;                                                                                           // Dietary exposure (µg/kg)

dxdt_AIR  = - AIR;                                                                                            // Exposure by inhalation (µg/L)

dxdt_SOIL = - SOIL;                                                                                           // Exposure by soil (µg/kg)

dxdt_DUST = - DUST;                                                                                           // Exposure by dust (µg/g)

dxdt_LUNG = k2_dust*(AIR * VInhalation) + k2_cig * Cig - LUNG*(k3 + k4);                                      // pulmonary region at t=T

dxdt_GUT = k5 * (DIET * wbw_f + SOIL + DUST + k1_cig * Cig + k1_dust * (AIR * VInhalation) + k4 * LUNG) - k6 * GUT;  // GI-tract

dxdt_UPTAKE1 =  k3*LUNG + k6*GUT - UPTAKE2 - UPTAKE3;                                                         // uptake pool

dxdt_PLASMA = UPTAKE3 + k10 * OTHER + k13 * LIVER - k9*PLASMA - k11 * PLASMA - kx * PLASMA + k18 *KIDNEY - k12 * PLASMA;                   // Plasma

dxdt_RBC = PLASMA * kx - k16 * RBC;                                                                           // Red Blood Cells

dxdt_META = UPTAKE2 + k14 * LIVER + k16 * RBC - k17x * META - k17b * META;                                     // Metallothionein

double BLOOD = (RBC + k20 * (PLASMA + META))/vb;                                                            // total blood

dxdt_LIVER = k12 * PLASMA - (k13 + k14 + k15) * LIVER;                                                        // Liver

dxdt_KIDNEY = k17x*META - k18 *KIDNEY - k19x * KIDNEY;                                                        // Kidney

double kidney_burden = (KIDNEY)/vk;                                                                         // kidney burden in ug/kg

dxdt_OTHER = k9 * PLASMA - k10 * OTHER;                                                                       // other tissues

double wb = BLOOD + LIVER + KIDNEY + OTHER + LUNG + GUT;                                                // body burden

dxdt_FECES = k11*PLASMA + k15*LIVER + (1-k5)*(wbw*DIET);                                                      // feces

dxdt_URINE = META * k17b + KIDNEY * k19x;                                                                     // urine cumulative

$CMT DIET AIR SOIL DUST LUNG GUT UPTAKE1 PLASMA RBC META LIVER KIDNEY OTHER FECES URINE

$CAPTURE year ucdcr wbw_f ucr BLOOD ur kidney_burden Conc_urine_cd
