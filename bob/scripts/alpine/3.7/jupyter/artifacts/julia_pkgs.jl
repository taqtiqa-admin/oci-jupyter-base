#!/usr/bin/env julia

# Package load for jupyter notebook container install
Pkg.init()
Pkg.update()
Pkg.add("HDF5")
Pkg.add("Gadfly")
Pkg.add("RDatasets")
Pkg.add("IJulia")
# Precompile Julia packages
using IJulia
