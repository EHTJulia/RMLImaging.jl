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

"""
    klentropy_base(x::AbstractArray, p::AbstractArray)

Base function of the l1norm.

# Arguments
- `I::AbstractArray`: the image
"""
function klentropy_base(x::AbstractArray, p::AbstractArray)::Float64
    nx = length(x)

    # compute the total flux
    totalflux = sum(x)

    # compute the KL divergence
    xnorm = x ./ totalflux
    value = sum(xnorm .* log.(xnorm ./ p))

    return value
end

function evaluate(::LinearDomain, reg::KLEntropy, skymodel::AbstractImage2DModel, x::AbstractArray)::Float64
    x_linear = transform_linear_forward(skymodel, x)
    return klentropy_base(x_linear, reg.prior)
end