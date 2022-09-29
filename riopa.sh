#!/bin/bash

readonly self_path=$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)

julia --project="${self_path}" "${self_path}/riopa.jl" "$@"
