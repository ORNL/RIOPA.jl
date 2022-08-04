FROM ubuntu:jammy

Label maintainer="Alexia Arthur arthur14@purdue.edu"

RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get clean &&\
    apt-get update -y &&\
    apt-get upgrade -y apt-utils &&\
    apt-get install -y gpg wget git

RUN  export DEBIAN_FRONTEND=noninteractive &&\
     cd /opt &&\
     wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.3-linux-x86_64.tar.gz

RUN  export DEBIAN_FRONTEND=noninteractive &&\
     cd /opt &&\
     tar -zxvf julia-1.7.3-linux-x86_64.tar.gz

ENV PATH "$PATH:/opt/julia-1.7.3/bin"

RUN export DEBIAN_FRONTEND=noninteractive &&\
    julia --project -e 'using Pkg; Pkg.add(["ADIOS2", "ArgParse", "HDF5", "MLStyle", "MPI", "OrderedCollections", "Polynomials", "Random", "YAML"]);'

