export L1Norm

"""
    L1Norm <: AbstractRegularizer

Regularizer using the l1-norm.

# fields
- `hyperparameter::Number`: the hyperparameter of the regularizer
- `weight`: the weight of the regularizer, which could be a number or an array.
- `domain::AbstractRegularizerDomain`: the image domain where the regularization funciton will be computed. L1Norm can be computed only in `LinearDomain()`.
"""
struct L1Norm <: AbstractRegularizer
    hyperparameter::Number
    weight
    domain::AbstractRegularizerDomain
end

# function label
functionlabel(::L1Norm) = :l1norm

"""
    l1norm(I::AbstractArray)

Base function of the l1norm.

# Arguments
- `I::AbstractArray`: the image
"""
@inline l1norm(x::AbstractArray) = @inbounds sum(abs.(x))

"""
    l1norm(I::AbstractArray, w::Number)

Base function of the l1norm.

# Arguments
- `I::AbstractArray`: the image
- `w::Number`: the regularization weight
"""
@inline l1norm(x::AbstractArray, w::Number) = w * l1norm(x)


"""
    evaluate(::AbstractRegularizer, skymodel::AbstractImage2DModel, x::AbstractArray)
"""
function evaluate(::LinearDomain, reg::L1Norm, skymodel::AbstractImage2DModel, x::AbstractArray)
    return l1norm(transform_linear_forward(skymodel, x), reg.weight)
end