"""
Template instantiation engine for antimony PBK models.
"""

import csv
import logging
import re
import yaml
from pathlib import Path


def load_yaml(path):
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def load_text(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def setup_logger(name="instantiate_template"):
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    if not logger.handlers:
        ch = logging.StreamHandler()
        ch.setLevel(logging.INFO)
        ch.setFormatter(logging.Formatter("[%(levelname)s] %(message)s"))
        logger.addHandler(ch)
    return logger


def write_text(path, content):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def parameters_to_antimony(parameters):
    lines = []
    for item in parameters:
        name = item["id"]
        if item["type"] == "constant":
            lines.append(f"{name} = {item['value']}")
        elif item["type"] == "variable":
            if "assignment" in item:
                lines.append(f"{name} := {item['assignment']}")
            else:
                lines.append(f"{name} = {item['value']}")
    return "\n".join(lines)

def rate_rules_to_antimony(rate_rules):
    lines = []
    for item in rate_rules:
        lines.append(f"{item['id']} = {item['assignment']}")
    return "\n".join(lines)

def instantiate(instance_config, template_text, logger):
    model_name = instance_config["model_name"]
    functions = instance_config.get("functions", [])
    blocks = instance_config.get("blocks", [])

    result = template_text
    result = result.replace("{{MODEL_NAME}}", model_name)

    for block in blocks:
        name = block["id"]
        parts = []
        if "parameters" in block:
            parts.append(parameters_to_antimony(block["parameters"]))
        if "rate_rules" in block:
            parts.append(rate_rules_to_antimony(block["rate_rules"]))
        indented = "    " + "\n\n".join(parts).replace("\n", "\n    ")
        result = result.replace("{{" + name + "}}", indented)

    if functions:
        func_parts = []
        for f in functions:
            params = ", ".join(f.get("parameters", []))
            func_parts.append(f"function {f['id']}({params})\n    {f['body'].strip()}\nend")
        result = "\n\n".join(func_parts) + "\n\n" + result

    unhandled = re.findall(r'\{\{(\w+)\}\}', result)
    for block in unhandled:
        logger.warning("Block '{{%s}}' in template was not handled (no matching block in config).", block)
    result = re.sub(r'\{\{\w+\}\}', '', result)

    return result


def create_instance_annotations(template_annotations_path, instance_config, output_path):
    template_path = Path(template_annotations_path)
    with template_path.open(encoding="utf-8") as f:
        reader = csv.DictReader(f)
        template_rows = list(reader)
    fieldnames = reader.fieldnames

    model_name = instance_config["model_name"]

    blocks = instance_config.get("blocks", [])
    yaml_params = []
    for block in blocks:
        yaml_params.extend(block.get("parameters", []))
    yaml_compartments = instance_config.get("compartments", [])

    existing = {(r["element_id"], r["sbml_type"]) for r in template_rows}

    new_rows = []
    for p in yaml_params:
        if (p["id"], "parameter") not in existing:
            new_rows.append({"element_id": p["id"], "sbml_type": "parameter",
                             "element_name": p.get("element_name", ""), "unit": p["unit"],
                             "annotation_type": "rdf", "qualifier": "BQM_IS",
                             "URI": "", "remark": ""})
            new_rows.append({"element_id": p["id"], "sbml_type": "parameter",
                             "element_name": p.get("element_name", ""), "unit": p["unit"],
                             "annotation_type": "rdf", "qualifier": "BQB_IS",
                             "URI": "", "remark": ""})
    for c in yaml_compartments:
        if (c["id"], "compartment") not in existing:
            new_rows.append({"element_id": c["id"], "sbml_type": "compartment",
                             "element_name": c.get("element_name", ""), "unit": c["unit"],
                             "annotation_type": "rdf", "qualifier": "BQM_IS",
                             "URI": "", "remark": ""})

    for row in template_rows:
        if row["sbml_type"] == "model":
            row["element_id"] = model_name

    all_rows = template_rows + new_rows

    with open(output_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_rows)


def process_instance(config_path, logger):
    logger.info("Processing %s", config_path)
    config = load_yaml(config_path)

    template_rel = config.get("template", "")
    template_path = (config_path.parent / template_rel).resolve()
    template_text = load_text(template_path)

    antimony_text = instantiate(config, template_text, logger)

    model_name = config["model_name"]
    output_path = config_path.parent / f"{model_name}.ant"
    write_text(output_path, antimony_text)
    logger.info("Generated %s", output_path)

    template_annotations = template_path.with_suffix('.annotations.csv')
    if template_annotations.exists():
        annotations_output = output_path.with_suffix('.annotations.csv')
        create_instance_annotations(template_annotations, config, str(annotations_output))
        logger.info("Generated annotations %s", annotations_output)
    else:
        logger.warning("No template annotations found at %s, skipping annotation generation.", template_annotations)


def main():
    logger = setup_logger()
    models_dir = Path("models")
    yamls = sorted(models_dir.rglob("*.yaml"))
    logger.info("Found %d YAML config(s) in %s", len(yamls), models_dir)
    for yaml_file in yamls:
        process_instance(yaml_file, logger)


if __name__ == "__main__":
    main()
