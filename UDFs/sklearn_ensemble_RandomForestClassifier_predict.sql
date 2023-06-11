/**
 * Input columns:
 * - "name": Name of the model (has to be specified when making predictions)
 * - "settings": Specify settings for this function to deviate from the standard functionality
 * - "index": Index by which every row can be identified
 * - "feature_0": Feature 0 of the training dataset
 * - "feature_1": Feature 1 of the training dataset
 * - ...
 * - "feature_n": Feature n of the training dataset
 */
CREATE OR REPLACE PYTHON3 SET SCRIPT ML.sklearn_ensemble_RandomForestClassifier_predict(...) EMITS (...) AS
import pandas as pd
import numpy as np
helper = exa.import_script('ML.HelperScript').Helper()
helper.ConnectionInit('ML_BUCKET')
def run(ctx):
  name = ctx[0]
  filename = helper.SafeFileNameCreate(name)
  settings = ctx[1]
  model = helper.LoadFromBucketFS(filename + '.dat')
  model.n_jobs = 1
  map_in = helper.LoadFromBucketFS(filename + '_map_in.json')
  map_out = helper.LoadFromBucketFS(filename + '_map_out.json')
  helper.PredictionStepInit(ctx, [ 2 ], range(3, exa.meta.input_column_count), map_in, 'ALL')
  (identifier, feature) = helper.PredictionStep()
  res_df = pd.DataFrame(columns=['identifier', 'label'])
  res_df['identifier'] = [ i[0] for i in identifier ]
  res_df['label'] = [ str(map_out[str(x)]) for x in model.predict(feature) ]
  ctx.emit(res_df)
def default_output_columns():
  length = exa.meta.input_columns[0].length
  col = 'identifier INT'
  if length % 100 != 0:
    col += ', label0 varchar(10000)'
  else:
    for k in range(int(length / 100)):
      col += ', label' + str(k) + ' varchar(10000)'
  return col
