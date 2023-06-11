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
CREATE OR REPLACE PYTHON3 SET SCRIPT ML.sklearn_svm_SVR_train(...) RETURNS /*name*/ VARCHAR(64) AS
import pandas as pd
import numpy as np
import json
from sklearn import svm
helper = exa.import_script('ML.HelperScript').Helper()
helper.ConnectionInit('ML_BUCKET')
def run(ctx):
  name = ctx[0]
  filename = helper.SafeFileNameCreate(name)
  if ctx[1] != '' and ctx[1] != None:
  	settings = json.loads(ctx[1])
  else:
  	settings = []
  helper.TrainingStepInit(ctx, 'regression', range(2, exa.meta.input_column_count - 1), [ exa.meta.input_column_count - 1 ], 'ALL')
  (feature, label) = helper.TrainingStep()
  model = svm.SVR()
  if "model_params" in settings:
    model.set_params(**settings["model_params"])
  model.fit(feature, label)
  helper.DumpToBucketFS(model, filename + '.dat')
  helper.DumpToBucketFS(helper.map_in, filename + '_map_in.json')
  return name
