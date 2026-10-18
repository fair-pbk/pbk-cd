"""Create validation scenarios (YAML) and processed reference series (CSV) for
the Amzal 2009, Kjellstrom 1978 and Leconte 2021 datasets in validation/reference_data."""
import os

import pandas as pd
import yaml

DATA_PATH = './validation/reference_data'
PROCESSED_PATH = os.path.join(DATA_PATH, 'processed')
SCENARIOS_PATH = './validation/scenarios'
DAYS_PER_YEAR = 365

MODEL_INSTANCE = {
    'id': 'PBK_Cd',
    'label': 'SBML',
    'model_path': './model/pbk_cd_gastellu_2026_revised.sbml',
    'param_file': './model/pbk_cd_gastellu_2026_revised.params.csv',
    'target_mappings': {
        'VBlood': 'vb',
        'BW': 'wbw',
        'AGut': 'GUT_LUMEN',
        'CKidney': 'KIDNEY / vk / 1000',
        'UrineCR': '(k_MT_out * k17b * META + k19x * KIDNEY) / ucr',
    },
}

OUTPUTS = {
    'UrineCR': {'id': 'UrineCR', 'label': 'Creatinine adjusted urine', 'output': 'UrineCR'},
    'CKidney': {'id': 'CKidney', 'label': 'Concentration in kidney', 'output': 'CKidney'},
}


def read_dataset(name):
    return pd.read_csv(os.path.join(DATA_PATH, f'{name}.csv'), sep=';', encoding='utf-8')


def write_reference(df, file_name, output_id):
    """Write a reference timeline (age in days, value) and return its relative path."""
    os.makedirs(PROCESSED_PATH, exist_ok=True)
    path = os.path.join(PROCESSED_PATH, file_name)
    out = pd.DataFrame({'time': df['age'].to_numpy() * DAYS_PER_YEAR, output_id: df['concentration'].to_numpy()})
    out.sort_values('time').to_csv(path, index=False)
    return path.replace('\\', '/').lstrip('./')


def make_scenario(sid, label, source, output_id, dose, adjustment, until_years,
                  duration_years, ref_file, ref_label):
    event = {
        'type': 'repeated_bolus',
        'target': 'AGut',
        'amount': float(dose),
        'time': 0,
        'interval': 1,
    }
    if adjustment:
        event['adjustment'] = adjustment
    if until_years is not None:
        event['until'] = int(until_years * DAYS_PER_YEAR)
    return {
        'id': sid,
        'label': label,
        'time_unit': 'DAY',
        'amount_unit': 'MICROGRAMS',
        'duration': int(duration_years * DAYS_PER_YEAR),
        'evaluation_resolution': 1,
        'dosing_events': [event],
        'parameters': {'Age': 0, 'sex': 1, 'AgeRef': 30, 'BWRef': 85},
        'outputs': [dict(OUTPUTS[output_id])],
        'reference_data': [{
            'id': source,
            'label': ref_label,
            'file_path': ref_file,
            'series_type': 'CHECKPOINTS',
            'time_unit': 'DAY',
            'mappings': {output_id: output_id},
        }],
    }


def write_yaml(sid, label, scenarios):
    doc = {'id': sid, 'label': label, 'model_instances': [MODEL_INSTANCE], 'scenarios': scenarios}
    with open(os.path.join(SCENARIOS_PATH, f'{sid}.yaml'), 'w', encoding='utf-8') as f:
        yaml.safe_dump(doc, f, sort_keys=False)


def main():
    # Amzal 2009: 0.3 ug/kg BW/day from birth to 70 years, creatinine adjusted urine at age 62-75
    df = read_dataset('amzal_2009')
    ref = write_reference(df, 'amzal_2009_urine.csv', 'UrineCR')
    write_yaml('amzal_2009', 'Amzal 2009', [make_scenario(
        'amzal_2009', 'Amzal 2009 - urinary cadmium', 'amzal_2009', 'UrineCR',
        df['dose'].iloc[0], 'BW', float(df['expo_end'].iloc[0]), 75, ref, 'Amzal 2009')])

    # Kjellstrom 1978: absolute daily dose from birth to 40 years, kidney cortex at 45 years
    df = read_dataset('kjellstrom_1978')
    scenarios = []
    for idx, row in df.reset_index(drop=True).iterrows():
        sid = f'kjellstrom_1978_{row["id"]}_{round(row["dose"])}ug'
        ref = write_reference(df.loc[[idx]], f'{sid}.csv', 'CKidney')
        scenarios.append(make_scenario(
            sid, f'Kjellstrom 1978 - set {row["id"]}, {row["dose"]:.0f} ug/day', 'kjellstrom_1978',
            'CKidney', row['dose'], None, float(row['expo_end']), float(row['age']) + 1,
            ref, 'Kjellstrom 1978'))
    write_yaml('kjellstrom_1978', 'Kjellstrom 1978', scenarios)

    # Leconte 2021: lifelong daily dose (ug/kg BW), urinary curve at age 0-62
    df = read_dataset('leconte_2021')
    scenarios = []
    for dose, sub in df.groupby('dose'):
        sid = f'leconte_2021_{str(dose).replace(".", "p")}'
        ref = write_reference(sub, f'{sid}.csv', 'UrineCR')
        scenarios.append(make_scenario(
            sid, f'Leconte 2021 - {dose} ug/kg BW/day', 'leconte_2021', 'UrineCR',
            dose, 'BW', None, 63, ref, 'Leconte 2021'))
    write_yaml('leconte_2021', 'Leconte 2021', scenarios)


if __name__ == '__main__':
    main()
