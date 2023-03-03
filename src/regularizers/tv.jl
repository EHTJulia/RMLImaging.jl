export TV

"""
    TV <: AbstractRegularizer

Regularizer using the Istropic Total Variation 

# fields
- `hyperparameter::Number`: the hyperparameter of the regularizer
- `weight`: the weight of the regularizer, which may be used for multi-dimensional images.
- `domain::AbstractRegularizerDomain`: the image domain where the regularization funciton will be computed.
"""
struct TV <: AbstractRegularizer
    hyperparameter::Number
    weight
    domain::AbstractRegularizerDomain
end

# function label
functionlabel(::TV) = :tv

"""
    tv_base_real(I::AbstractArray)

Base function of the istropic total variation.

# Arguments
- `I::AbstractArray`: the input two dimensional real image
"""
function tv_base_real(I::AbstractArray)
    nx = size(I, 1)
    ny = size(I, 2)
    value = 0
    for iy = 1:ny, ix = 1:nx
        if ix < nx
            @inbounds ΔIx = I[ix+1, iy] - I[ix, iy]
        else
            ΔIx = 0
        end

        if iy < ny
            @inbounds ΔIy = I[ix, iy+1] - I[ix, iy]
        else
            ΔIy = 0
        end

        value += √(ΔIx^2 + ΔIy^2)
    end
    return value
end

function ChainRulesCore.rrule(::typeof(tv_base_real), x::AbstractArray)
    y = tv_base_real(x)
    function pullback(Δy)
        f̄ = NoTangent()
        v̄ = @thunk(tv_base_real_grad(x) * Δy)
        return f̄, v̄
    end
    return y, pullback
end

@inline function tv_base_real_grad(I::AbstractArray)
    nx = size(I, 1)
    ny = size(I, 2)
    grad = zeros(nx, ny)
    for iy = 1:ny, ix = 1:nx
        @inbounds grad[ix, iy] = tv_base_real_grad(I, ix, iy)
    end
    return grad
end

@inline function tv_base_real_grad(I::AbstractArray, ix::Int64, iy::Int64)::Float64
    nx = size(I, 1)
    ny = size(I, 2)

    i1 = ix
    j1 = iy
    i0 = i1 - 1
    j0 = j1 - 1
    i2 = i1 + 1
    j2 = j1 + 1

    grad = 0.0

    #
    # For ΔIx = I[i+1,j] - I[i,j], ΔIy = I[i,j+1] - I[i,j]
    #
    #   ΔIx = I[i+1,j] - I[i,j]
    if i2 > nx
        ΔIx = 0.0
    else
        @inbounds ΔIx = I[i2, j1] - I[i1, j1]
    end

    #   ΔIy = I[i,j+1] - I[i,j]
    if j2 > ny
        ΔIy = 0.0
    else
        @inbounds ΔIy = I[i1, j2] - I[i1, j1]
    end

    # compute variation and its gradient
    tv = √(ΔIx^2 + ΔIy^2)
    if tv > 0
        grad += -(ΔIx + ΔIy) / tv
    end

    #
    # For ΔIx= I[i,j]-I[i-1,j], ΔIy = I[i-1,j]-I[i-1,j]
    #
    if (i0 > 0)
        # ΔIx = I[i,j] - I[i-1,j]
        @inbounds ΔIx = I[i1, j1] - I[i0, j1]

        # ΔIy = I[i-1,j+1] - I[i-,j]
        if j2 > ny
            ΔIy = 0
        else
            @inbounds ΔIy = I[i0, j2] - I[i0, j1]
        end

        # compute variation and its gradient
        tv = √(ΔIx^2 + ΔIy^2)
        if tv > 0
            grad += ΔIx / tv
        end
    end

    #
    #   For ΔIx= I[i+1,j-1]-I[i,j-1], ΔIy = I[i,j]-I[i,j-1]
    #
    if (j0 > 0)
        # ΔIx= I[i+1,j-1] - I[i,j-1]
        if i2 > nx
            ΔIx = 0
        else
            @inbounds ΔIx = I[i2, j0] - I[i1, j0]
        end

        # ΔIy = I[i,j] - I[i,j-1]
        @inbounds ΔIy = I[i1, j1] - I[i1, j0]

        # compute variation and its gradient
        tv = √(ΔIx^2 + ΔIy^2)
        if tv > 0
            grad += ΔIy / tv
        end
    end

    return grad
end

"""
    tv_base_real(I::AbstractArray, w::Number)

Base function of the istropic total variation.

# Arguments
- `I::AbstractArray`: the input two dimensional real image
- `w::Number`: the regularization weight
"""
function tv_base_real(I::AbstractArray, w::Number)
    return w * tv_base_real(I)
end

function evaluate(::LinearDomain, reg::TV, skymodel::AbstractImage2DModel, x::AbstractArray)
    x_linear = transform_linear_forward(skymodel, x)
    return tv_base_real(x_linear, reg.weight)
end

function evaluate(::ParameterDomain, reg::TV, skymodel::AbstractImage2DModel, x::AbstractArray)
    return tv_base_real(x, reg.weight)
end