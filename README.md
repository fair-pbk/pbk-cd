# Cadmium PBK model 

This repository contains a revised implementation of the cadmium PBK model of [Gastellu et al., 2026](https://doi.org/10.1016/j.fct.2024.115111).

## Building the SBML and running the validation scipts

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

### Run validation scenarios

To run the run simulation scenarios, type:

```
python ./scripts/run_validation.py
```

By default, this script reuses existing outputs from previous runs. To override and recalculate outputs that already exist, use the `-f` option.
