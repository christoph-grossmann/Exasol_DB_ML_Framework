/**
 * Input columns:
 * - "name": Name of the model (has to be specified when making predictions)
 * - "settings": Specify settings for this function (as JSON)
 * - "feature_0": Feature 0 of the training dataset
 * - "feature_1": Feature 1 of the training dataset
 * - ...
 * - "feature_n": Feature n of the training dataset
 * - "label": Label of the training dataset (for multiple festures use settings)
 */
CREATE OR REPLACE PYTHON3 SET SCRIPT ML.sklearn_linear_model_LinearRegression_train(...) RETURNS /*name*/ VARCHAR(64) AS
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
helper = exa.import_script('ML.HelperScript').Helper()
helper.ConnectionInit('ML_BUCKET')
def run(ctx):
  name = ctx[0]
  filename = helper.SafeFileNameCreate(name)
  settings = ctx[1]
  helper.TrainingStepInit(ctx, 'regression', [ 2 ], [ 3 ], 'ALL')
  (x, y) = helper.TrainingStep()
  model = LinearRegression().fit(np.array(x).reshape((-1, 1)), y)
  helper.DumpToBucketFS(model, filename + '.dat')
  return name
 