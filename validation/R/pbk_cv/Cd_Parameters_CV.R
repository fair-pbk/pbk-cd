# Rate Constants and biokinetic variables
# Rate and toxicokinetic values (empirical value from Kjellström et Nordberg, 1978; Béchaux et al. 2014; Pouillot et al. 2022)

theta <- c(
  
  # Respiratory deposition fractions
  k1_cig  = 0.10,      # Fraction of inhaled cigarette Cd deposited in NP/TB airways
  k1_dust = 0.70,      # Fraction of inhaled dust Cd deposited in NP/TB airways
  
  k2_cig  = 0.40,      # Fraction of inhaled cigarette Cd deposited in pulmonary region
  k2_dust = 0.13,      # Fraction of inhaled dust Cd deposited in pulmonary region
  
  # Uptake pool
  k3      = 0.05,      # Transfer from lung compartment to uptake pool (/day)
  k4      = 0.005,     # Transfer from lung compartment to GI tract (/day)
  
  # Gastrointestinal absorption
  k5_h    = 0.05,      # Fraction of GI Cd retained in epithelium (male)
  k5_f    = 0.10,      # Fraction of GI Cd retained in epithelium (female)
  
  k6      = 0.05,      # Transfer from GI tract to uptake pool (/day)
  
  # Blood uptake and metallothionein formation
  k7      = 0.25,      # Fraction of uptake pool Cd entering metallothionein pathway
  k8      = 1.0,       # Maximum metallothionein uptake capacity (µg/day?)
  
  # Plasma (B1) distribution
  k9      = 0.44,      # Plasma -> other tissues (/day)
  k10     = 0.00014,   # Other tissues -> plasma (/day)
  
  k11     = 0.27,      # Plasma -> feces (/day)
  
  k12     = 0.25,      # Plasma -> liver (/day)
  k13     = 0.00003,   # Liver -> plasma (/day)
  
  k14     = 0.00016,   # Liver -> metallothionein pool (/day)
  k15     = 0.00005,   # Liver -> feces (/day)
  
  # Red blood cells (B2)
  kx       = 0.04,     # Plasma -> RBC (/day)
  k16      = 0.012,    # RBC -> metallothionein pool (/day)
  
  # Metallothionein pool (B3)
  k17      = 0.95,     # Fraction of metallothionein Cd transferred to kidney
  # Remaining fraction (1-k17) eliminated in urine
  
  # Kidney
  k18      = 0.00001,  # Kidney -> plasma (/day)
  
  k19      = 0.00014,  # Baseline kidney -> urine elimination (/day)
  k21      = 0.0000011,# Age-related increase in kidney elimination after age 30 (/day)
  
  # Blood concentration calculation
  k20      = 0.10,      # Fraction of plasma + metallothionein pools contributing # to measured whole-blood Cd
  
  # NEW ITEM: Addeded to be able to study these parameters more explicitly if wanted
  fabs_ing = 1,         # absorbed fraction from in GI tract
  king_release = 1,     # Release rate in GI tract(/day)
  fabs_inh = 1,         # absorbed fraction in lung
  kinh_release = 1,     # Release rate in lung (/day)
  fabs_derm = 0.05/100, # absorbed fraction from skin to plasma 
  kderm_release = 1     # Release rate from skin to plasma (/day)
)



