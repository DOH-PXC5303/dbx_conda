# dbx_conda

Image hosted on [Docker Hub](https://hub.docker.com/repository/docker/dohpxc5303/dbx_conda/general)

Dockerfile for using Miniconda with Databricks. The Dockerfile combines the databricksruntime [standard](https://github.com/databricks/containers/tree/master/ubuntu/standard) Dockerfile, the [dbfsfuse](https://github.com/databricks/containers/tree/master/ubuntu/dbfsfuse) Dockerfile, and the [python-conda](https://github.com/databricks/containers/tree/master/ubuntu/python-conda) Dockerfile. Some of the resulting images were using older builds that had several severe known vulnerabilities. Several parts were updated to overcome this: 
- [Ubuntu](https://hub.docker.com/_/ubuntu) image: updated from 18.04 to 22.04
- Miniconda: updated from py38_4.9.2 to py38_23.11.0-2
- [databricksruntime/minimal](https://hub.docker.com/r/databricksruntime/minimal) image: updated from 9.x to 14.3-LTS
- pyarrow: updated from 1.0.1 to 14.0.1
