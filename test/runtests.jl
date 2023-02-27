# PyPlot needs to be build before testing because EHTImages.jl uses it.
using Pkg
ENV["PYTHON"] = ""
Pkg.build("PyCall")
using PyPlot
#----
using RMLImaging
using Test

@testset "RMLImaging.jl" begin
    # Write your tests here.
end
