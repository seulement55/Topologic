#!/bin/bash
set -e

# Miniconda targets binaries for macOS 11, so use them.
MACOSMAJORVER=11

# Determine Python version. Corresponding conda_env_topologic_py*.yml
# must exist.
PYTHONVER=312
if [ ! -z "$1" ]; then PYTHONVER=$1; fi
if [ ! -z "$2" ]; then MACOSMAJORVER=$2; fi
set --

export MACOSX_DEPLOYMENT_TARGET=${MACOSMAJORVER}.0
#PLAT_NAME=macosx_${MACOSX_DEPLOYMENT_TARGET//./_}_arm64
export TOPOLOGIC_PLAT_NAME=macosx_${MACOSX_DEPLOYMENT_TARGET//./_}_arm64

# Obtain project root/top directory and stay in it.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/..
TOP_DIR=$(pwd)

# Install and activate Miniconda.
if [ ! -d "$HOME/miniconda" ]; then
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -O ~/miniconda.sh
  bash ~/miniconda.sh -b -p $HOME/miniconda
fi
source ~/miniconda/bin/activate

# Make sure Miniconda environment is created.
if conda info --envs | grep -q topologic_py${PYTHONVER}; then
  echo "Well done, conda environment already created."
else
  conda env create -f conda_env_topologic_py${PYTHONVER}.yml
fi

# Activate Miniconda environment.
conda activate topologic_py${PYTHONVER}
python --version

# Build the project.
cd TopologicPythonBindings
python build_macos.py

# Run the tests.
pip install wheelhouse/topologic-5.0.0-cp${PYTHONVER}-cp${PYTHONVER}-${TOPOLOGIC_PLAT_NAME}.whl

cd test
python topologictest01.py
python topologictest02.py

echo "Python bindings have been built successfully."
