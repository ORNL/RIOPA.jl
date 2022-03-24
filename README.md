# RIOPA.jl

Reproducible Input Ouput (I/O) Pattern Application (RIOPA).
Proxy app for I/O generation in the U.S. Department of Energy Exascale Computing
Project using Julia.

Requires: 
- [Julia](https://julialang.org/downloads/) v1.6 or later


## Getting started
It's helpful to set the environment variable `JULIA_MPI_PATH` to the top-level
MPI installation directory. In addition, if `mpiexec` is not the proper run
command for your system, set the environment variable `JULIA_MPI_EXEC` to the
desired run command. See the MPI package
[configuration](https://juliaparallel.github.io/MPI.jl/stable/configuration/)
page for more options if necessary.

From top-level RIOPA directory run
```
$ julia --project[=.]
```
```
julia> ]
(RIOPA) pkg> instantiate
(RIOPA) pkg> build
(RIOPA) pkg> <Ctrl-D>
```

## Test Suite
```
$ julia --project ./test/runtests.jl
```

## Minimal Functionality ("hello") Mode 
```
$ julia --project riopa.jl [(-c | --config) <config-file>] hello
```
This may be run in parallel with `mpirun` or the like.

## Generate a Configuration File
```
$ julia --project riopa.jl [(-c | --config) <config-filename>] generate-config
```
If no filename is given, the generated file will be called "default.yaml"
