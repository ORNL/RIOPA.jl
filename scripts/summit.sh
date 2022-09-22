#!/bin/bash

module load git
module load hdf5
module load julia

export JULIA_HDF5_PATH="$OLCF_HDF5_ROOT/bin"
export JULIA_MPI_PATH=$OLCF_SPECTRUM_MPI_ROOT
export JULIA_MPI_BINARY=system

julia --project -e 'using Pkg; Pkg.build(verbose=true)'

