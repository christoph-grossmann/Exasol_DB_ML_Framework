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
CREATE OR REPLACE PYTHON3 SET SCRIPT ML.sklearn_linear_model_LinearRegression_predict(...) EMITS (identifier INT, y DOUBLE) as
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
  helper.PredictionStepInit(ctx, [ 2 ], [ 3 ], None, 'ALL')
  (identifier, feature) = helper.PredictionStep()
  res_df = pd.DataFrame(columns=['identifier', 'y'])
  res_df['identifier'] = [ i[0] for i in identifier ]
  res_df['y'] = model.predict(np.array([ f[0] for f in feature ]).reshape((-1, 1)))
  ctx.emit(res_df)
 