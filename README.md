[![Documentation Status](https://readthedocs.org/projects/riopajl/badge/?version=latest)](https://riopajl.readthedocs.io/en/latest/?badge=latest)

# RIOPA.jl

Reproducible Input Ouput (I/O) Pattern Application (RIOPA).
Proxy app for I/O generation using Julia funded by the U.S. Department of Energy
Exascale Computing Project.

Requires: 
- [Julia](https://julialang.org/downloads/) v1.6 or later


## Getting started
It's helpful to set the following environment variables:

- `JULIA_MPI_PATH=<MPI-installation-prefix>`
- `JULIA_MPI_BINARY=system`
- `JULIA_HDF5_PATH=<path-to-HDF5-binaries>` (may be necessary in order to use
  HDF5 in parallel see [HDF5.jl docs](https://juliaio.github.io/HDF5.jl/stable/#Setting-up-Parallel-HDF5))

In addition, if `mpiexec` is not the proper run command for your system, set the
environment variable `JULIA_MPI_EXEC` to the desired run command (such as `srun`
or `jsrun`). See the MPI package
[configuration](https://juliaparallel.github.io/MPI.jl/stable/configuration/)
page for more options if necessary.

From top-level RIOPA directory run
```
julia --project[=.]
```
```
julia> ]
(RIOPA) pkg> instantiate
(RIOPA) pkg> build
(RIOPA) pkg> <Ctrl-D>
```

### Test Suite
```
julia --project ./test/runtests.jl
```

### Minimal Functionality ("hello") Mode 
```
julia --project riopa.jl [(-c | --config) <config-file>] hello
```
Using the default configuration:
```bash
julia --project riopa.jl hello
```
or in parallel:
```
mpirun -n 4 julia --project riopa.jl hello
```

### Generate a Configuration File
```
julia --project riopa.jl [(-c | --config) <config-filename>] generate-config
```
If no filename is given, the generated file will be given a generic name.
