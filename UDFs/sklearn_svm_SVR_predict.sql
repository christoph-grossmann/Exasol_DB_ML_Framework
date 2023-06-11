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
CREATE OR REPLACE PYTHON3 SET SCRIPT ML.sklearn_svm_SVR_predict(...) EMITS (identifier INT, label varchar(10000)) as
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
  helper.PredictionStepInit(ctx, [ 2 ], range(3, exa.meta.input_column_count), map_in, 'ALL')
  (identifier, feature) = helper.PredictionStep()
  res_df = pd.DataFrame(columns=['identifier', 'label'])
  res_df['identifier'] = [ i[0] for i in identifier ]
  res_df['label'] = [ str(l) for l in model.predict(feature) ]
  ctx.emit(res_df)
