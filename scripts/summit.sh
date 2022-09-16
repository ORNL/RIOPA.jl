#!/bin/bash

module load julia

export JULIA_MPI_BINARY=system
export JULIA_MPI_PATH=$OLCF_SPECTRUM_MPI_ROOT
export JULIA_HDF5_PATH="$OLCF_HDF5_ROOT/bin"

julia --project -e 'using Pkg; Pkg.build(verbose=true)'

