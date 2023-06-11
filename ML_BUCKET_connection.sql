
CREATE OR REPLACE CONNECTION ML_BUCKET
TO '{ "host": "localhost", "port": 2580, "is_https": false, "bucketfs_name": "bfsdefault", "bucket_name": "default", "path": "/ML" }'
USER 'w'
IDENTIFIED BY 'write';
