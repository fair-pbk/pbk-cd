__Physiologically Based Kinetic (PBK) model for Cadmium (Cd)__

This repository develop a PBK model for Cd in SBML.

The project is developed in the framework of PARC (WP 6 & 8).

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