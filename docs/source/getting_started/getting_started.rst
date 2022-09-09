Getting Started
===============

It's helpful to set the following environment variables:

- ``JULIA_MPI_PATH=<MPI-installation-prefix>``
- ``JULIA_MPI_BINARY=system``
- ``JULIA_HDF5_PATH=<path-to-HDF5-binaries>`` (may be necessary in order to use
  HDF5 in parallel see [HDF5.jl docs](https://juliaio.github.io/HDF5.jl/stable/#Setting-up-Parallel-HDF5))

In addition, if ``mpiexec`` is not the proper run command for your system, set the
environment variable ``JULIA_MPI_EXEC`` to the desired run command (such as ``srun``
or ``jsrun``). See the MPI package
[configuration](https://juliaparallel.github.io/MPI.jl/stable/configuration/)
page for more options if necessary.

From top-level RIOPA directory run

.. code-block:: console

    julia --project[=.]

.. code-block:: julia

   julia> ]
   (RIOPA) pkg> instantiate
   (RIOPA) pkg> build
   (RIOPA) pkg> <Ctrl-D>

Test Suite
----------

.. code-block:: console

   julia --project ./test/runtests.jl

Minimal Functionality ("hello") Mode 
------------------------------------

.. code-block:: console

   julia --project riopa.jl [(-c | --config) <config-file>] hello

Using the default configuration:

.. code-block:: console

   julia --project riopa.jl hello

or in parallel:

.. code-block:: console

   mpirun -n 4 julia --project riopa.jl hello

Generate a Configuration File
-----------------------------

.. code-block:: console

   julia --project riopa.jl [(-c | --config) <config-filename>] generate-config

If no filename is given, the generated file will be given a generic name.
