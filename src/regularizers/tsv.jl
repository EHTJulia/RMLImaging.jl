export TSV

"""
    TSV <: AbstractRegularizer

Regularizer using the Istropic Total Squared Variation 

# fields
- `hyperparameter::Number`: the hyperparameter of the regularizer
- `weight`: the weight of the regularizer, which may be used for multi-dimensional images.
- `domain::AbstractRegularizerDomain`: the image domain where the regularization funciton will be computed.
"""
struct TSV <: AbstractRegularizer
    hyperparameter::Number
    weight
    domain::AbstractRegularizerDomain
end

"""
    tsv_base_real(I::AbstractArray)

Base function of the istropic total squared Variation.

# Arguments
- `I::AbstractArray`: the input two dimensional real image
"""
@inline function tsv_base_real(I::AbstractArray)::Float64
    nx = size(I, 1)
    ny = size(I, 2)

    value = 0
    for iy in 1:ny, ix in 1:nx-1
        ΔI = I[ix+1, iy] - I[ix, iy]
        value += ΔI^2
    end
    for iy in 1:ny-1, ix in 1:nx
        ΔI = I[ix, iy+1] - I[ix, iy]
        value += ΔI^2
    end
    return value
end

function ChainRulesCore.rrule(::typeof(tsv_base_real), x::AbstractArray)
    y = tsv_base_real(x)
    function pullback(Δy)
        f̄ = NoTangent()
        v̄ = @thunk(tsv_base_real_grad(x) * Δy)
        return f̄, v̄
    end
    return y, pullback
end

@inline function tsv_base_real_grad(I::AbstractArray)
    nx = size(I, 1)
    ny = size(I, 2)
    grad = zeros(nx, ny)
    for iy in 1:ny, ix in 1:nx
        grad[ix, iy] = tsv_base_real_grad(I, ix, iy)
    end
    return grad
end

@inline function tsv_base_real_grad(I::AbstractArray, ix::Int64, iy::Int64)::Float64
    nx = size(I, 1)
    ny = size(I, 2)

    i1 = ix
    j1 = iy
    i0 = i1 - 1
    j0 = j1 - 1
    i2 = i1 + 1
    j2 = j1 + 1

    grad = 0.0

    # For ΔIx = I[i+1,j] - I[i,j]
    if i2 < nx + 1
        grad += -2 * (I[i2, j1] - I[i1, j1])
    end

    # For ΔIy = I[i,j+1] - I[i,j]
    if j2 < ny + 1
        grad += -2 * (I[i1, j2] - I[i1, j1])
    end

    # For ΔIx = I[i,j] - I[i-1,j]
    if i0 > 0
        grad += +2 * (I[i1, j1] - I[i0, j1])
    end

    # For ΔIy = I[i,j] - I[i,j-1]
    if j0 > 0
        grad += +2 * (I[i1, j1] - I[i1, j0])
    end

    return grad
end

"""
    tsv_base_real(I::AbstractArray, w::Number)

Base function of the istropic total squared Variation.

# Arguments
- `I::AbstractArray`: the input two dimensional real image
- `w::Number`: the regularization weight
"""
@inline function tsv_base_real(I::AbstractArray, w::Number)
    return w * tsv_base_real(I)
end

function evaluate(::LinearDomain, reg::TSV, skymodel::AbstractImage2DModel, x::AbstractArray)
    x_linear = transform_linear_forward(skymodel, x)
    return tsv_base_real(x_linear, reg.weight)
end

function evaluate(::ParameterDomain, reg::TSV, skymodel::AbstractImage2DModel, x::AbstractArray)
    return tsv_base_real(x, reg.weight)
end