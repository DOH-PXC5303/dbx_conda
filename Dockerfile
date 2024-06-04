# PC edits: updated image version from 18.04 to 22.04
FROM ubuntu:22.04 as builder

RUN apt-get update && apt-get install --yes \
    wget \
    libdigest-sha-perl \
    bzip2

# Download miniconda and use it to install the conda binary
# PC edits: updated miniconda from py38_4.9.2 to py38_23.11.0-2
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-py38_23.11.0-2-Linux-x86_64.sh -O miniconda.sh \
    # Conda must be installed at /databricks/conda
    && /bin/bash miniconda.sh -b -p /databricks/conda \
    && rm miniconda.sh

# PC edits: updated image version from 9.x to 14.3-LTS
FROM databricksruntime/minimal:14.3-LTS

COPY --from=builder /databricks/conda /databricks/conda

# PC edits: updated pyarrow pip version from 1.0.1 to 14.0.1
COPY env.yml /databricks/.conda-env-def/env.yml

RUN /databricks/conda/bin/conda env create --file /databricks/.conda-env-def/env.yml \
    # Source conda.sh for all login shells.
    && ln -s /databricks/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

# Conda recommends using strict channel priority speed up conda operations and reduce package incompatibility problems.
# Set always_yes to avoid needing -y flags, and improve conda experience in Databricks notebooks.
RUN /databricks/conda/bin/conda config --system --set channel_priority strict \
    && /databricks/conda/bin/conda config --system --set always_yes True

# This environment variable must be set to indicate the conda environment to activate.
# Note that currently, we have to set both of these environment variables. The first one is necessary to indicate that this runtime supports conda.
# The second one is necessary so that the python notebook/repl can be started (won't work without it)
ENV DEFAULT_DATABRICKS_ROOT_CONDA_ENV=dcs-minimal
ENV DATABRICKS_ROOT_CONDA_ENV=dcs-minimal

RUN apt-get update \
  && apt-get install -y fuse \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Make sure the USER env variable is set. The files exposed
# by dbfs-fuse will be owned by this user.
# Within the container, the USER is always root.
ENV USER root

RUN apt-get update \
  && apt-get install -y openssh-server \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Warning: the created user has root permissions inside the container
# Warning: you still need to start the ssh process with `sudo service ssh start`
RUN useradd --create-home --shell /bin/bash --groups sudo ubuntu
