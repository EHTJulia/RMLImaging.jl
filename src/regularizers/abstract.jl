export domain
export evaluate
export functionlabel
export hyperparameter
export LinearDomain
export ParameterDomain


"""
    AbstractRegularizer

# Mandatory fields

- `hyperparameter::Number`: the hyper parameter of the regularization function. In default, it should be a number.
- `domain::RegularizerDomain`: the domain of the image space where the regularization function will be computed.

# Mandatory methods

- `evaluate(::AbstractRegularizerDomain, ::AbstractRegularizer, ::AbstractImageModel, ::AbstractArray)`: 
    Evaluate the regularization function for the given input sky image.
- `evaluate(::AbstractRegularizer, ::AbstractImageModel, ::AbstractArray)`: 
    Evaluate the regularization function for the given input sky image.
- `cost(::AbstractRegularizer, ::AbstractImageModel, ::AbstractArray)`: 
    Evaluate the cost function for the given input sky image. The cost function is defined by the product of its hyperparameter and regularization function.
- ``
"""
abstract type AbstractRegularizer end


# computing domain
abstract type AbstractRegularizerDomain end

# computing domain
struct LinearDomain <: AbstractRegularizerDomain end
struct ParameterDomain <: AbstractRegularizerDomain end


# function to get the label for regularizer
functionlabel(::AbstractRegularizer) = :namelessregularizer


# function to get domain and hyper parameter
"""
    domain(reg::AbstractRegularizer) = reg.domain

Return the computing domain of the given regularizer.
"""
domain(reg::AbstractRegularizer) = reg.domain


"""
hyperparameter(reg::AbstractRegularizer) = reg.hyperparameter

Return the hyperparameter of the given regularizer.
"""
hyperparameter(reg::AbstractRegularizer) = reg.hyperparameter


"""
    evaluate(domain::AbstractRegularizerDomain, reg::AbstractRegularizer, skymodel::AbstractImageModel, x::AbstractArray)

Compute the value of the given regularization function for the given image parameters
on the given image model. In default, return 0.

# Arguments
- `domain::AbstractRegularizerDomain`: the domain of the image where the regularization function will be computed.
- `reg::AbstractRegularizer`: the regularization function.
- `skymodel::AbstractImageModel`: the model of the input image
- `x::AbstractArray`: the parameters of the input image
"""
evaluate(::AbstractRegularizerDomain, ::AbstractRegularizer, ::AbstractImageModel, ::AbstractArray) = 0


"""
    evaluate(reg::AbstractRegularizer, skymodel::AbstractImageModel, x::AbstractArray)

Compute the value of the given regularization function for the given image parameters
on the given image model. In default, return evaluate(domain(reg), reg, skymodel, x).

# Arguments
- `reg::AbstractRegularizer`: the regularization function.
- `skymodel::AbstractImageModel`: the model of the input image
- `x::AbstractArray`: the parameters of the input image
"""
evaluate(reg::AbstractRegularizer, skymodel::AbstractImageModel, x::AbstractArray) = evaluate(reg.domain, reg, skymodel, x)


"""
    cost(reg::AbstractRegularizer, skymodel::AbstractImageModel, x::AbstractArray)

Compute the cost function of the given regularization function for the given image parameters
on the given image model. In default, this should return `reg.hyperparameter .* evaluate(reg, skymodel, x)`.

# Arguments
- `reg::AbstractRegularizer`: the regularization function.
- `skymodel::AbstractImageModel`: the model of the input image
- `x::AbstractArray`: the parameters of the input image
"""
function cost(reg::AbstractRegularizer, skymodel::AbstractImageModel, x::AbstractArray)
    return reg.hyperparameter .* evaluate(reg, skymodel, x)
end