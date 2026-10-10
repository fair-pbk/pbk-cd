"""
Description:
This script creates default model parametrisation files for all SBML files
in the specified models path.

Usage:
Run the script from the command line with the following syntax:
  python models/create_default_parametrisations.py

Dependencies:
See requirements.txt (install using `pip install -r requirements.txt`).
"""

import argparse
from pathlib import Path
import uuid
import libsbml as ls
import logging

from sbmlpbkutils import ParametrisationsTemplateGenerator

MODELS_PATH = './model/'
PARAMETRISATIONS_PATH = './parametrisations/'
CITATION_FILE = None

def create_file_logger(logfile: str) -> logging.Logger:
    logger = logging.getLogger(uuid.uuid4().hex)
    logger.setLevel(logging.DEBUG)
    fh = logging.FileHandler(logfile, 'w+')
    formatter = logging.Formatter('[%(levelname)s] - %(message)s')
    fh.setFormatter(formatter)
    logger.addHandler(fh)
    return logger

def create_default_parametrisation_file(sbml_file, out_file):
    print(f"Creating default parametrisation file [{out_file}].")
    params_generator = ParametrisationsTemplateGenerator()
    document = ls.readSBML(sbml_file)
    default_params = params_generator.generate(
        document.getModel(),
        model_instance_ids=[f'{sbml_file.stem}_default'],
    )[1]
    default_params.to_csv(out_file, index=False)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Create default parametrisations script arguments.")
    parser.add_argument(
        '-o',
        '--overwrite',
        action="store_true",
        default=False,
        help="Overwrite files if they already exist."
    )
    args = parser.parse_args()
    overwrite = args.overwrite

    for sbml_file in Path(MODELS_PATH).rglob('*.sbml'):
        out_file = Path(PARAMETRISATIONS_PATH) / f"{sbml_file.stem}_default_params.csv"
        if overwrite or not Path(out_file).exists():
            create_default_parametrisation_file(sbml_file, out_file)
