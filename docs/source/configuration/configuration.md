# Configuration

A RIOPA simulation is specified by a YAML configuration file. This file is a
multi-level hierarchy, since we want to flexibly model I/O patterns in terms of
<dataset, step, [level, ...], rank>. Below is listed an example config file that
demonstrates most of the features of RIOPA, followed by a reference describing
each of the configuration keywords.

example.yaml
```yaml
datasets:
  - type: "output"
    name: "plot"
    basename: "plt"
    io_backend: "HDF5"
    nsteps: 10
    step_conversion_factor: 10
    compute_seconds: 1.0
    data_streams:
      - name: "Level_0"
        initial_size_range:
          - 3000
          - 3600
        evolution:
          function: "GrowthFactor"
          params: [ 1.15 ]
        proc_payload_groups:
          - size_ratio: "1/3"
            proc_ratio: 0.5
          - size_ratio: "2/3"
            proc_ratio: 0.5
      - name: "Level_1"
        initial_size_range:
          - 6000
          - 7200
        evolution:
          function: "Polynomial"
          params: [ 0.0 1.0 ]
        proc_payload_groups:
          - size_ratio: "1/3"
            proc_ratio: "1/4"
          - size_ratio: "2/3"
            proc_ratio: "3/4"
  - type: "output"
    name: "checkpoint restart"
    basename: "chk"
    io_backend: "IOStream"
    nsteps: 3
    step_conversion_factor: 30
    compute_seconds: 3.0
    data_streams:
      - name: "Level_0"
        initial_size_range:
          - 3000
          - 3600
        proc_payload_groups:
          - size_ratio: "1/3"
            proc_ratio: 0.1
          - size_ratio: "2/3"
            proc_ratio: 0.9
      - name: "Level_1"
        initial_size_range:
          - 6000
          - 7300
        proc_payload_groups:
          - size_ratio: "1/3"
            proc_ratio: "1/8"
          - size_ratio: "2/3"
            proc_ratio: "7/8"
```

## Reference

```yaml
datasets:
  - ...
 [- ...]
```

### Datasets
The `datasets` keyword introduces a list of dataset configurations (with list
elements denoted by the `-`). Each is a separate series of I/O operations that
may have completely different rules for when and how data is written (or read).

 - __`type:`__ Must be either `"input"` or `"output"`
 - __`name:`__ Full name for what the dataset represents
 - __`basename:`__ Literal string base for sequences of files or directories
 - __`io_backend:`__ Choose which file format to use:
   - `"IOStream"`
   - `"HDF5"`
 - __`nsteps:`__ How many times this I/O operation will take place in sequence
 - __`step_conversion_factor:`__ For some models if the number of I/O steps is not
   the same as the number of steps (*e.g.*, time steps) that meaningful to the
   application, you can use this to convert. This allows for the `evolution`
   `function` to be expressed in terms of the application step. So, for example,
   if the application you are modeling writes output every 10 time steps, you
   would have `step_conversion_factor: 10` and specify your `evolution`
   `function` with respect to time steps.
 - __`compute_seconds:`__ Time (in seconds) for simulating application compute time
   between I/O steps for this dataset. RIOPA will use a "sleep" operation
   to simulate compute time between I/O steps.
 - __`data_streams:`__ List of data stream configurations.

### Data Streams

All the data streams for a given output dataset are written in the same
operation, but each stream represents a distinct aspect of the output and may
have different rules for how data grows and is distributed among process ranks.

 - __`name:`__ Literal string used for naming files or directories. You may
   arbitrarily nest stream directories using a `/`, like `name: "a/b/c"`
 - __`initial_size_range:`__ List of two (integer) values specifying the total
   size of the output at the first I/O step. This is specified as a range to
   allow for variablity in output. Note that the evolution function below is
   applied to both limits in the range so that for each stream (and then for
   each rank executing the stream) there is a range of sizes that can be used.
   If you want to avoid this variability, just use the same number twice.
 - __`evolution:`__ Group specifying how the data size grows from step to step
   - __`function:`__ Name of function type to use. Must be one of the following:
     - `"GrowthFactor"`
     - `"Polynomial"`
   - __`params:`__ List of coefficients that fully specify the function
     - For `"GrowthFactor"`, there must only be one parameter, which is the
       growth factor
     - For `"Polynomial"`, there can be one or more parameters, which act as
       $[a_1, a_2, ...]$. That is, the constant term $a_0$ is left out. This
       term is already provided, derived from the `initial_size_range`

### Payload Groups

Process payload groups are specified with size ratio and process ratio. These
ratios may be given as fractions (or Julia Rationals) in quotes or as floating
point values.

 - __`proc_payload_groups:`__ List of payload group configurations for
   distributing the payload across groups of processes (ranks). This allows for
   more fine-grained control of how I/O operations behave. If this is not
   needed, simply specify one group with both the `size_ratio` and the
   `proc_ratio` set to 1.0
   - __`size_ratio:`__ Portion of stream output size executed by this group of
     processes
   - __`proc_ratio:`__ Portion of processes belonging to this group

Note that the `size_ratio` entries must sum to 1.0. Likewise for the
`proc_ratio` entries.
