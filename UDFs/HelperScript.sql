
CREATE OR REPLACE PYTHON3 SCALAR SCRIPT ML.HelperScript() RETURNS INT AS
import pickle
import json
import datetime
from tempfile import NamedTemporaryFile
from exasol_bucketfs_utils_python import upload
from exasol_bucketfs_utils_python.bucket_config import BucketConfig
from exasol_bucketfs_utils_python.bucketfs_config import BucketFSConfig
from exasol_bucketfs_utils_python.bucketfs_connection_config import BucketFSConnectionConfig
class Helper():
  def debug(this, msg):
    print('%s: vm_id: %s node_id %s > %s' % (datetime.datetime.now(), exa.meta.vm_id, exa.meta.node_id, msg))
  def SafeFileNameCreate(this, filename):
    keepcharacters = ('.', '_', '-')
    filename = str.replace(filename, 'Ä', 'Ae')
    filename = str.replace(filename, 'Ö', 'Oe')
    filename = str.replace(filename, 'Ü', 'Ue')
    filename = str.replace(filename, 'ä', 'ae')
    filename = str.replace(filename, 'ö', 'oe')
    filename = str.replace(filename, 'ü', 'ue')
    filename = str.replace(filename, 'ß', 'ss')
    return "".join(c for c in filename if c.isalnum() or c in keepcharacters).rstrip()
  def ConnectionInit(this, connectionName):
    connection = exa.get_connection(connectionName)
    if connection == None:
      raise Exception("The connection '" + connectionName + "' does not exist.")
    con = json.loads(connection.address)
    this.connection_config = BucketFSConnectionConfig(
      host = str(con["host"]).strip() or "localhost",
      port = con["port"] or 2580,
      user = connection.user.strip() or "w",
      pwd = connection.password.strip() or "write",
      is_https = con["is_https"] or False
      )
    this.bucketfs_config = BucketFSConfig(
      connection_config = this.connection_config,
      bucketfs_name = con["bucketfs_name"].strip() or "bfsdefault"
      )
    this.bucket_config = BucketConfig(
      bucket_name = con["bucket_name"].strip() or "default",
      bucketfs_config = this.bucketfs_config
      )
    this.path = con["path"]
  def DumpToBucketFS(this, element, filename):
    buffer = pickle.dumps(element)
    with NamedTemporaryFile() as input_temp_file:
      input_temp_file.write(buffer)
      input_temp_file.flush()
      input_temp_file.seek(0)
      upload.upload_fileobj_to_bucketfs(
        bucket_config = this.bucket_config,
        bucket_file_path = this.path + "/" + filename,
        fileobj = input_temp_file)
  def LoadFromBucketFS(this, filename):
    return pickle.load(open('/buckets/' + this.bucketfs_config.bucketfs_name
      + '/' + this.bucket_config.bucket_name + this.path + '/' + filename, 'rb'))
  def TrainingStepInit(this, ctx, mltype, feature_range, label_range, batch_rows = 'ALL'):
    ctx.reset()
    this.ctx = ctx
    this.mltype = mltype
    this.feature_range = feature_range
    this.label_range = label_range
    this.batch_rows = batch_rows
    this.input_index = 0
    this.map_index = 0
    this.map_in = {}
    this.map_out = {}
    this.strcol = [ col.type == str for col in exa.meta.input_columns ]
  def TrainingStep(this):
    if not this.StepNext():
      return (None, None)
    feature = []
    label = []
    if str(this.batch_rows).upper() == 'ALL':
      this.batch_rows = this.ctx.size()
    for i in range(this.batch_rows):
      row = []
      for k in this.feature_range:
        if this.strcol[k]:
          row.append(this.MapIntegrate(this.ctx[k]))
        else:
          row.append(this.ctx[k])
      feature.append(row)
      if str.lower(this.mltype) == 'c' or str.lower(this.mltype) == 'classification':
        label.append([ this.MapIntegrate(this.ctx[k]) for k in this.label_range ])
      else:
        label.append([ this.ctx[k] for k in this.label_range ])
      this.input_index += 1
      if not this.ctx.next():
        break
    return (feature, label)
  def PredictionStepInit(this, ctx, identifier_range, feature_range, map_in, batch_rows = 'ALL'):
    ctx.reset()
    this.ctx = ctx
    this.identifier_range = identifier_range
    this.feature_range = feature_range
    this.batch_rows = batch_rows
    this.input_index = 0
    this.map_index = -1
    this.map_in = map_in
    this.strcol = [ col.type == str for col in exa.meta.input_columns ]
  def PredictionStep(this):
    if not this.StepNext():
      return (None, None)
    identifier = []
    feature = []
    if str(this.batch_rows).upper() == 'ALL':
      this.batch_rows = this.ctx.size()
    for i in range(this.batch_rows):
      identifier.append([ this.ctx[k] for k in this.identifier_range ])
      if this.map_in is None:
        feature.append([ this.ctx[k] for k in this.feature_range ])
      else:
        row = []
        for k in this.feature_range:
          if this.strcol[k]:
            row.append(this.MapPredIntegrate(this.ctx[k]))
          else:
            row.append(this.ctx[k])
        feature.append(row)
      this.input_index += 1
      if not this.ctx.next():
        break
    return (identifier, feature)
  def StepNext(this):
    return not (this.input_index == this.ctx.size())
  def MapIntegrate(this, value):
    if value in this.map_in:
      return this.map_in[ value ]
    else:
      this.map_in[ value ] = this.map_index
      this.map_out[ str(this.map_index) ] = value
      index = this.map_index
      this.map_index += 1
      return index
  def MapPredIntegrate(this, value):
    if value in this.map_in:
      return this.map_in[ value ]
    else:
      this.map_in[ value ] = this.map_index
      index = this.map_index
      this.map_index -= 1
      return index
