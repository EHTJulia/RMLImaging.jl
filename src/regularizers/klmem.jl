export KLEntropy

"""
    KLEntropy <: AbstractRegularizer

Regularizer using the Kullback-Leibler divergence (or a relative entropy).

# fields
- `hyperparameter::Number`: the hyperparameter of the regularizer
- `prior`: the prior image.
- `domain::AbstractRegularizerDomain`: the image domain where the regularization funciton will be computed.
    KLEntropy can be computed only in `LinearDomain()`.
"""
struct KLEntropy <: AbstractRegularizer
    hyperparameter::Number
    prior
    domain::AbstractRegularizerDomain
end

functionlabel(::KLEntropy) = :klentropy

"""
    klentropy_base(x::AbstractArray, p::AbstractArray)

Base function of the l1norm.

# Arguments
- `I::AbstractArray`: the image
"""
@inline function klentropy_base(x::AbstractArray, p::AbstractArray)
    # compute the total flux
    totalflux = sum_floop(x, ThreadedEx())
    # compute xlogx
    @inbounds xnorm = x ./ totalflux
    @inbounds xlogx = xnorm .* log.(xnorm ./ p)
    return sum(xlogx)
end

function evaluate(::LinearDomain, reg::KLEntropy, skymodel::AbstractImage2DModel, x::AbstractArray)
    return klentropy_base(transform_linear_forward(skymodel, x), reg.prior)
end