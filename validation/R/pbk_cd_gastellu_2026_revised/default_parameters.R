# Rate Constants and biokinetic variables
# Rate and toxicokinetic values (empirical value from Kjellström et Nordberg, 1978; Béchaux et al. 2014; Pouillot et al. 2022)

theta <- c(

  # ==========================================================
  # Respiratory deposition fractions
  # ==========================================================

  k1_cig  = 0.10,      # Fraction of inhaled cigarette Cd deposited in airways and transferred to GI tract (-)
  k1_dust = 0.70,      # Fraction of inhaled airborne dust Cd deposited in NP/TB airways and subsequently transferred to GI tract (-)
  k2_cig  = 0.40,      # Fraction of inhaled cigarette Cd deposited in pulmonary region (-)
  k2_dust = 0.13,      # Fraction of inhaled airborne dust Cd deposited in pulmonary region (-)

  # ==========================================================
  # Respiratory clearance and systemic uptake
  # ==========================================================

  k3      = 0.05,      # First-order transfer rate constant from lung to systemic uptake (/day)
  k4      = 0.005,     # First-order transfer rate constant from lung to GI tract (/day)

  # ==========================================================
  # GI processing and absorption
  # ==========================================================

  kabs    = 1,         # First-order GUT processing/emptying rate constant (/day); added to explicitly define the rate associated with partitioning GUT Cd between intestinal transfer and feces
  k5_h    = 0.05,      # Fraction of processed GUT Cd transferred to the intestinal compartment in males (-)
  k5_f    = 0.10,      # Fraction of processed GUT Cd transferred to the intestinal compartment in females (-)
  k6      = 0.05,      # First-order transfer rate constant from intestinal compartment to systemic uptake (/day)

  # ==========================================================
  # Systemic uptake and metallothionein pathway
  # ==========================================================

  k7      = 0.25,      # Fraction of total systemic Cd uptake directed to the metallothionein pathway (-)
  k8      = 1.0,       # Maximum Cd flux from systemic uptake into the metallothionein pathway (ug/day)

  # ==========================================================
  # Plasma (B1) distribution and elimination
  # ==========================================================

  k9      = 0.44,      # First-order transfer rate constant from plasma to other tissues (/day)
  k10     = 0.00014,   # First-order transfer rate constant from other tissues to plasma (/day)
  k11     = 0.27,      # First-order elimination rate constant from plasma to feces (/day)
  k12     = 0.25,      # First-order transfer rate constant from plasma to liver (/day)
  k13     = 0.00003,   # First-order transfer rate constant from liver to plasma (/day)
  k14     = 0.00016,   # First-order transfer rate constant from liver to metallothionein pool (/day)
  k15     = 0.00005,   # First-order elimination rate constant from liver to feces (/day)

  # ==========================================================
  # Red blood cells
  # ==========================================================

  kx      = 0.04,      # First-order transfer rate constant from plasma to red blood cells (/day)
  k16     = 0.012,     # First-order transfer rate constant from red blood cells to metallothionein pool (/day)

  # ==========================================================
  # Metallothionein pool
  # ==========================================================

  k17     = 0.95,      # Baseline fraction of MT-bound Cd removal directed to kidney; remaining fraction is directed to urine (-)
  k_MT_out = 1,        # First-order turnover/removal rate constant for MT-bound Cd (/day); added explicitly for unit consistency

  # ==========================================================
  # Kidney
  # ==========================================================

  k18     = 0.00001,   # First-order transfer rate constant from kidney to plasma (/day)
  k19     = 0.00014,   # Baseline first-order elimination rate constant from kidney to urine (/day)
  k21     = 0.0000011, # Age-dependent increase in kidney-to-urine elimination after age 30 (see age-dependent physiology function)

  # ==========================================================
  # Whole-blood Cd calculation
  # ==========================================================

  k20     = 0.10,      # Fraction of plasma + metallothionein Cd amounts contributing to calculated whole-blood Cd (-)

  # ==========================================================
  # Exposure availability and release
  # ==========================================================
  # NEW ITEMS: Addeded to be able to study these parameters more explicitly if wanted
  f_ing_available = 1, # Fraction of ingested Cd available for entry into the modeled GI tract (-)
  king_release = 1,    # First-order release rate constant for ingested Cd source compartments (/day)
  f_inh_available = 1, # Fraction of inhaled Cd available for the modeled respiratory deposition/absorption pathway (-)
  kinh_release = 1,    # First-order release rate constant for cigarette Cd source compartment (/day)
  f_derm_available = 0.05/100, # Fraction of dermally applied/available Cd transferred to plasma (-)
  kderm_release = 1    # First-order release rate constant from dermal exposure source compartments (/day)
)

