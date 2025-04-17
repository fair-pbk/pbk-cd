import unittest
import sys
import os
import tellurium as te
import pandas as pd
from parameterized import parameterized
from helpers import plot_simulation_results, load_parametrisation

sys.path.append('../sbmlpbkutils/')

__test_outputs_path__ = './tests/__testoutputs__'

class ExposureScenarioTests(unittest.TestCase):

    def setUp(self):
        from pathlib import Path
        Path(__test_outputs_path__).mkdir(parents=True, exist_ok=True)

    @parameterized.expand([
        (1, 100),
        (2, 1000),
        (3, 30000)
    ])
    def test_daily_oral_bolus(self, id_scenario, days_of_exposure):
        # Exposure scenario
        scenario_id = f'test_daily_oral_bolus_{id_scenario}'
        input_id = 'AGut'
        daily_intake = 1 # 1 ug/kg bw/d
        days_after_exposure = int(days_of_exposure / 10)
        num_days = days_of_exposure + days_after_exposure
        evaluation_frequency = 1 # evals per unit of time

        # Load the PBPK model from the SBML file
        model_file = os.path.join('model/PBK_Cd.ant')
        rr_model = te.loada(model_file)

        # Make sure A_gut is not constant and does not have boundary conditions
        rr_model.setInitAmount(input_id, 0)
        rr_model.setConstant(input_id, False)
        rr_model.setBoundary(input_id, False)

        # Set chemical parameters
        load_parametrisation(rr_model, './parametrisations/PBK_Cd_default_params.csv', 'PBK_Cd_PARAM')

        # Create a repeating daily oral dosing
        eid = f"oral_daily_exposure"
        rr_model.addEvent(eid, False, f"time % 1 == 0 && time < {days_of_exposure}", False)
        rr_model.addEventAssignment(eid, input_id, f"{input_id} + {daily_intake} * BW", False)
        rr_model.regenerateModel(True, True)

        # Simulate the PBPK model
        plot_params = rr_model.timeCourseSelections + ['BW', 'Age']
        rr_model.setIntegrator('cvode')
        results = rr_model.simulate(0, num_days, evaluation_frequency * num_days + 1, plot_params)

        # Save to CSV file
        csv_filename = os.path.join(__test_outputs_path__, f'{scenario_id}.csv')
        df = pd.DataFrame(results, columns=results.colnames)
        df.to_csv(csv_filename, index=False)
        fig = plot_simulation_results(results, rr_model.timeCourseSelections)
        png_filename = os.path.join(__test_outputs_path__, f'{scenario_id}.png')
        fig.savefig(png_filename)

if __name__ == '__main__':
    unittest.main()
