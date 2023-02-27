export transform_linear_forward
export transform_linear_inverse


"""
    AbstractImageModel

# Mandatory fields

# Optional methods

# Mandatory methods

# Optional methods
"""
abstract type AbstractImageModel end


"""
    transform_linear_forward(model::AbstractImageModel, x::AbstractArray)

Convert the input array of the image model parameters into the corresponding
array of the linear-scale intensity map. This is supposed to be the inverse
funciton of ``transform_linear_inverse``.

# Arguments
- `model::AbstractImageModel`: the image model
- `x::AbstractArray`: the array of the image model parameters
"""
transform_linear_forward(::AbstractImageModel, x::AbstractArray) = x


"""
    transform_linear_forward(model::AbstractImageModel, x::AbstractArray)

Convert the input array of the linear-scale intensity map into the array of the 
corresponding model parameters. This is supposed to be the inverse
funciton of ``transform_linear_forward``.

# Arguments
- `model::AbstractImageModel`: the image model
- `x::AbstractArray`: the array of the linear-scale intensity map
"""
transform_linear_inverse(::AbstractImageModel, x::AbstractArray) = x