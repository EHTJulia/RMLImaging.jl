# RMLImaging
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ehtjulia.github.io/RMLImaging.jl/dev/)
[![Build Status](https://github.com/EHTJulia/RMLImaging.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/EHTJulia/RMLImaging.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/EHTJulia/RMLImaging.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/EHTJulia/RMLImaging.jl)

This module provides radio astornomy tool kits of the Regularized Maximum Likelihood (RML) imaging methods of radio interferometry. The current versions focus on the implementation of RML imaging methods for high-angular-resolution imaging within a modest field-of-view where the direction-dependent effects are ignoreable. The tool kits and algorithms are designed to meet the need of multi-dimensional imaging with Very Long Baseline Interferometry (e.g. Event Horizon Telescope) and millimeter interferometry (e.g. ALMA). The library aims to provide the following features:
- Julia native implementation of the end-to-end RML Imaging process: all the codes involved in RML Imaging methods are described in Julia. This allows significant accerelation from popular python implementations of RML imaging methods, with keeping the easiness to install the package and its dependencies. The Julia-native codes allow to utilize various powerful packages in the Julia's ecosystem --- this also offers a potential to scale the entire code to GPU and clusters easily in future.
- A set of data types and functions for the sky intensity distributions, non-uniform fast Fourier transformations (NUFFT), regularization functions, data likelihood functions, and optimization to solve images. Julia's effiecient way of the abstructing data types and its function allows interested users to implement their own imaging methods.
- AD-friendly implementation: the relevant functions for imaging (e.g., forward/adjoint transforms from sky images to Fourier-domain visibiltiies, regularization functions) are compatible with Automatic differentiation (AD) packages in [the Julia's ChainRules ecosystem](https://juliadiff.org/ChainRulesCore.jl/stable/), for instance [Zygote.jl](https://fluxml.ai/Zygote.jl/stable/). This allows easier implementation of algorithms using complicated sky models or set of data products. 

## Installation
Assuming that you already have Julia correctly installed, it suffices to import RMLImaging.jl in the standard way:

```julia
using Pkg
Pkg.add("RMLImaging")
```

## Documentation
The documentation is in preparation, but docstrings of available functions are listed for the [latest](https://ehtjulia.github.io/RMLImaging.jl/dev) version. The stable version has not been released. 

## Acknowledgement
The development of this package has been finantially supported by the following programs.
- v0.1.0 - v0.1.1: [ALMA North American Development Study Cycle 8](https://science.nrao.edu/facilities/alma/science_sustainability/alma-develop-history), National Radio Astronomy Observatory (NRAO), USA

The National Radio Astronomy Observatory is a facility of the National Science Foundation operated under cooperative agreement by Associated Universities, Inc.