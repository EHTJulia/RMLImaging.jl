export SingleNFFT2D
export forward
export adjoint

"""
    FourierTransform2D <: AbstractFourierTransform

Abstract type for Fourier Transform Operators of a single 2D image.
"""
abstract type FourierTransform2D <: AbstractFourierTransform end


"""
    SingleNFFT2D(nfft_fwd, nfft_adj, vnorm) <: FourierTransform2D

A Fourier Transform Operator of a single 2D Image using NFFT.

# Fields
- `nfft_fwd`: NFFT operator for the forward transform
- `nfft_adj`: NFFT operator for the adjoint transform
- `Vkernel`: the factor (phase shift, pulse funciton, kernel, etc) to be multipled by the forward-transformed visibilities.
"""
struct SingleNFFT2D <: FourierTransform2D
    nfft_forward
    nfft_adjoint
    Vkernel
end

function SingleNFFT2D(imagemodel, uvcoverage::SingleUVCoverage)::SingleNFFT2D
    # important constant: DO NOT CHANGE
    ftsign = +1   # Radio Astronomy data assumes the positive exponent in the forward operation V = Σ I exp(+2πux)

    # image parameters
    xref, yref = imagemodel.refpixel    # reference position in the unit of pixel
    Δx, Δy = imagemodel.pixelsize   # pixel size in radian
    Nx, Ny = imagemodel.imagesize   # number of pixels

    # uv-coverage (in lambda)
    u = uvcoverage.u
    v = uvcoverage.v
    uΔx = u .* -Δx # Δx in metadata is positive, so flip the sign for the left-handed sky coordinate
    vΔy = v .* Δy
    Nuv = size(u)[1]

    # k-vector for NFFT
    k = fill(-1.0 * ftsign, (2, Nuv)) # first -1 is to cancel the negative exponent (i.e. -2πfn) in the forward operation
    for iuv in 1:Nuv
        @inbounds k[1, iuv] *= uΔx[iuv]
        @inbounds k[2, iuv] *= vΔy[iuv]
    end

    # factor for the phase center
    @inbounds Vkernel = exp.(1im .* ftsign .* 2π .* (uΔx .* (Nx / 2 + 1 - xref) .+ vΔy .* (Ny / 2 + 1 - yref)))

    # pulse function will be added here.

    # initialize NFFT Plan
    nfft_forward = NFFT.plan_nfft(k, (Nx, Ny))
    nfft_adjoint = NFFT.adjoint(nfft_forward)

    return SingleNFFT2D(nfft_forward, nfft_adjoint, Vkernel)
end

@inline function forward(ft::SingleNFFT2D, x::Matrix{Float64})
    return forward(ft, complex(x))
end

@inline function forward(ft::SingleNFFT2D, x::Matrix{ComplexF64})
    @inbounds v = ft.nfft_forward * x
    @inbounds v .*= ft.Vkernel
    return v
end

function ChainRulesCore.rrule(::typeof(forward), ft::SingleNFFT2D, x::Matrix{ComplexF64})
    y = forward(ft, x)
    function pullback(Δy)
        f̄bar = NoTangent()
        ftbar = NoTangent()
        xbar = @thunk(adjoint(ft, Δy))
        return f̄bar, ftbar, xbar
    end
    return y, pullback
end

@inline function adjoint(ft::SingleNFFT2D, v::Vector)
    @inbounds vinp = v ./ ft.Vkernel
    @inbounds xadj = real(ft.nfft_adjoint * vinp)
    return xadj
end