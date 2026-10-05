# Cadmium PBK model 

This repository contains a revised, FAIR reimplementation of the cadmium PBK model developed by [Gastellu et al. (2026)](https://doi.org/10.1016/j.fct.2024.115111), which was itself based on the model originally developed by [Kjellström and Nordberg (1978)](https://doi.org/10.1016/0013-9351(78)90160-3).

Compared with the model from Gastellu et al., the present implementation includes two distinct types of changes. The first concerns model revisions, involving changes to the model formulation itself. The second concerns the FAIR reimplementation, involving changes required to encode the model in Antimony/SBML in accordance with the [FAIR PBK standard](https://doi.org/10.1016/j.comtox.2026.100426). The resulting SBML (FAIR) representation of the model is provided in [pbk_cd_gastellu_2026_revised.sbml](model/pbk_cd_gastellu_2026_revised.sbml).

## Model implementation

The file [pbk_cd_gastellu_2026_revised.ant](model/pbk_cd_gastellu_2026_revised.ant) contains the Antimony implementation of the model. A diagram of the model compartments and species is shown below.

![Model diagram of the EuroMix PBK model](docs/pbk_cd_gastellu_2026_revised.report.svg)

### Revision of model equations

Key changes in the revised model:

- **GI compartments:** the original model uses one gut state whereas the revised model distinguishes gut lumen from intestinal tissue.
- **Added absorption rate constant:** explicit gut processing through a first-order absorption rate constant was added to fix an inconsistency in the units.
- **Systemic uptake calculation:** the revised model calculates total systemic uptake algebraically from lung and intestinal transfer.
- **Uptake-pool state:** unlike the original model, which has a dynamic uptake pool, the revised model does not carry that intermediate pool as a state; its flux is calculated algebraically instead.
- **Uptake partitioning:** the revised model sends systemic uptake to metallothionein (MT) or plasma using the `k7` fraction and `k8` maximum-flux limit whereas the original partitions the dynamic uptake pool between its MT and plasma outflows.
- **Physiology aggregation:** the original calculates total body weight from a set of detailed organ and tissue volumes. The revised physiology retains volumes used directly by the Cd model and assigns the remainder to `OTHER` so that the organ-volume total closes to body weight.
- **Age range guard:** The revised implementation guards selected age-dependent equations at their upper age ranges.

### FAIR PBK reimplementation

The following changes were made to the Antimony/SBML reimplementation for compliance with the FAIR PBK standard:

- The Antimony model replaces the hard `min(k7 * TOTAL_UPTAKE, k8)` cap with a smooth approximation around `k8` to improve numerical stability. It is close to, but not mathematically identical to, the piecewise cap used in R.
- The Antimony model apportions the capped uptake back to lung- and GI-derived fluxes so those flows can be represented separately in its reaction network. Their sum defines the same total uptake pathway, subject to the smoothed cap.
- Cord-blood initialization is represented as an initial amount in the RBC species, calculated from `Ccord` and the birth blood volume. The R revised implementation does not express this initialization in the same way.
- In compliance with the standard, dosing is excluded from the Antimony/SBML model. Accordingly, exposure sources and their associated reactions are not represented in the reimplementation.

## SBML conversion and model annotation

Conversion to the annotated SBML file is done through the script [create_sbml.py]. This script first converts the Antimony model implementation to SBML and then annotates this SBML file using the annotations specified in the [pbk_cd_gastellu_2026_revised.annotations.csv](model/pbk_cd_gastellu_2026_revised.annotations.csv) file. After this, it performs a validation on the generated SBML file to check for consistency and completeness of the annotations of units and terms.

The annotations CSV file that is used for annotation links the different model elements (e.g., compartments and parameters) to ontological terms and specifies the units of measure. The model and model-element annotations are specified in accordance with the [FAIR PBK standard](https://fair-pbk.github.io/fair-pbk-standard/) specification. Note that although the Antimony format also allows for specification of units and annotation of model elements directly, they are here maintained in a separate csv file. This is to keep the model implementation in the Antimony file cleaner and easier to read.

## Validation

The SBML implementation is validated against the original and revised R reference implementations and the mrgsolve implementation using single-dose, repeated-dose, and lifetime-dosing scenarios. Scenario definitions, reference scripts, run instructions, and output details are documented in the [validation README](validation/README.md).

## Running the scipts

### Prerequisites

To run scripts you will need Python installed on your system, along with several additional packages. You can install these packages using the following command:

```
pip install -r requirements.txt
```

### Compile model

To convert the Antimony model implementation to SBML and annotates it, type:

```
python ./scripts/compile_model.py
```

### Create model docs

To create the [model documentation page](docs/pbk_cd_gastellu_2026_revised.report.md), type:

```
python ./scripts/create_report.py
```

### Run validation scenarios

To run the run simulation scenarios, type:

```
python ./scripts/run_validation.py
```

By default, this script reuses existing outputs from previous runs. To override and recalculate outputs that already exist, use the `-f` option.

To run the run simulation scenarios for a specific scenario config (e.g. thos defined in [validation/scenarios/R.yaml](validation/scenarios/R.yaml)), type:

```
python ./scripts/run_validation.py -c validation/scenarios/R.yaml
```
