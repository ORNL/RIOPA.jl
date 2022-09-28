# Summit (OLCF)

1. Load necessary modules
```
module load git hdf5 julia
```

2. Set environment variables
```bash
export JULIA_HDF5_PATH="$OLCF_HDF5_ROOT/bin"
export JULIA_MPI_PATH=$OLCF_SPECTRUM_MPI_ROOT
export JULIA_MPI_BINARY=system
```

3. Build package
```
julia --project -e 'using Pkg; Pkg.build(verbose=true)'
```
