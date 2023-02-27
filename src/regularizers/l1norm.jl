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


"""
    l1norm(I::AbstractArray)

Base function of the l1norm.

# Arguments
- `I::AbstractArray`: the image
"""
@inline function l1norm(x::AbstractArray)
    return sum(abs.(x))
end


"""
    l1norm(I::AbstractArray, w::Number)

Base function of the l1norm.

# Arguments
- `I::AbstractArray`: the image
- `w::Number`: the regularization weight
"""
@inline function l1norm(x::AbstractArray, w::Number)
    return w * l1norm(x)
end


"""
    l1norm(I::AbstractArray, w::Number)

Base function of the l1norm.

# Arguments
- `I::AbstractArray`: the image
- `w::AbstractArray`: the regularization weight which should have the same size with I
"""
@inline function l1norm(x::AbstractArray, w::AbstractArray)
    return l1norm(w .* x)
end


"""
    evaluate(::AbstractRegularizer, skymodel::AbstractImage2DModel, x::AbstractArray)
"""
function evaluate(::LinearDomain, reg::L1Norm, skymodel::AbstractImage2DModel, x::AbstractArray)
    x_linear = transform_linear_forward(skymodel, x)
    return l1norm(x_linear, reg.weight)
end