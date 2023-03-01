# RMLImaging
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ehtjulia.github.io/RMLImaging.jl/dev/)
[![Build Status](https://github.com/EHTJulia/RMLImaging.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/EHTJulia/RMLImaging.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/EHTJulia/RMLImaging.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/EHTJulia/RMLImaging.jl)

This module provides radio astornomy tool kits of the Regularized Maximum Likelihood (RML) Imaging methods of radio interferometry, in particular, for Very Long Baseline Inteferometry arrays including the Event Horizon Telescope (EHT) or next-generation Event Horizon Telescope (ngEHT). The library aims to provide:

- Julia native implementation of the end-to-end RML Imaging process: all the codes involved in RML Imaging methods are described in Julia. This allows significant accerelation from popular python implementations of RML imaging methods, with keeping the easiness to install the package and its dependencies. The Julia-native codes allow to utilize various powerful packages in the Julia's ecosystem --- this also offers a potential to scale the entire code to GPU and clusters easily in future.
- A set of data types and functions for the sky intensity distributions, non-uniform fast Fourier transformations (NUFFT), regularization functions, data likelihood functions, and optimization to solve images. Julia's effiecient way of the abstructing data types and its function allows interested users to implement their own imaging methods.
- AD-friendly implementation: the relevant functions for imaging (e.g., forward/adjoint transforms from sky images to Fourier-domain visibiltiies, regularization functions) are compatible with Automatic differentiation (AD) packages in [the Julia's ChainRules ecosystem](https://juliadiff.org/ChainRulesCore.jl/stable/), for instance [Zygote.jl](https://fluxml.ai/Zygote.jl/stable/). This allows easier implementation of algorithms using complicated sky models or set of data products. 

## Documentation
The [latest](https://ehtjulia.github.io/RMLImaging.jl/dev) version available. The stable version has not been released. 