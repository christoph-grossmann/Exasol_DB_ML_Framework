/**
 * Input columns:
 * - "name": Name of the model or "?<submodule> <function<"
 */
CREATE OR REPLACE PYTHON3 SCALAR SCRIPT ML.sklearn_params_get("name" VARCHAR(1000)) EMITS ("attribute" VARCHAR(1000), "value" varchar(10000)) as
import pandas as pd
import importlib
helper = exa.import_script('ML.HelperScript').Helper()
helper.ConnectionInit('ML_BUCKET')
def run(ctx):
  if ctx.name == '' or ctx.name == 'None':
    return
  elif ctx[0] == '?':
    names = ctx[1:].split(' ')
    module = importlib.import_module("sklearn." + names[0])
    model = getattr(module, names[1])()
  else:
    model = helper.LoadFromBucketFS(ctx.name + '.dat')
  dict = model.get_params(deep = False)
  res_df = pd.DataFrame(columns=['attribute', 'value'])
  res_df['attribute'] = [ str(x) for x in dict.keys() ]
  res_df['value'] = [ str(x) for x in dict.values() ]
  ctx.emit(res_df)
