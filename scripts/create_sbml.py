"""
Description:
This script creates the annotated SBML files from the Antimony PBK model implementations.

Usage:
Run the script from the command line with the following syntax:
  python models/create_sbml.py

Dependencies:
See requirements.txt (install using `pip install -r requirements.txt`).
"""

from pathlib import Path
import uuid
import tellurium as te
import libsbml as ls
import logging

from sbmlpbkutils import PbkModelValidator
from sbmlpbkutils import PbkModelAnnotator

MODELS_PATH = './models/'
CITATION_FILE = None

def create_file_logger(logfile: str) -> logging.Logger:
    logger = logging.getLogger(uuid.uuid4().hex)
    logger.setLevel(logging.DEBUG)
    fh = logging.FileHandler(logfile, 'w+')
    formatter = logging.Formatter('[%(levelname)s] - %(message)s')
    fh.setFormatter(formatter)
    logger.addHandler(fh)
    return logger

def compile_models():
    print("Creating SBML")
    for ant_file in Path(MODELS_PATH).rglob('*.ant'):
        if ant_file.name.endswith('.template.ant'):
            continue
        ant_file = str(ant_file)
        sbml_file = Path(ant_file).with_suffix('.sbml')

        print(f"Creating SBML file [{sbml_file}] from Antimony file [{ant_file}].")
        r = te.loada(ant_file)
        r.exportToSBML(sbml_file, current=False)

        document = ls.readSBML(sbml_file)

        annotations_file = Path(sbml_file).with_suffix('.annotations.csv')
        if not annotations_file.exists():
            print(f"ERROR: Annotations file [{annotations_file}] not found. "
                  f"Generate it first via instantiate_template.py or provide a manual annotations CSV.")
            continue

        annotations_log_file = Path(sbml_file).with_suffix('.annotations.log')
        annotated_sbml_file = Path(sbml_file).with_suffix('.sbml')
        annotator = PbkModelAnnotator()
        logger = create_file_logger(str(annotations_log_file))
        print(f"Creating annotated SBML file [{annotated_sbml_file}] from SBML file [{sbml_file}] with annotations file [{annotations_file}].")
        annotator.annotate(
            document,
            str(annotations_file),
            CITATION_FILE,
            logger = logger
        )
        ls.writeSBML(document, str(annotated_sbml_file))

        validation_log_file = Path(sbml_file).with_suffix('.validation.log')
        validator = PbkModelValidator()
        logger = create_file_logger(str(validation_log_file))
        validator.validate(str(annotated_sbml_file), logger)

if __name__ == '__main__':
    compile_models()
