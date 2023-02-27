export initialize

abstract type AbstractImage2DModel <: AbstractImageModel end

struct IS_POSITIVE end
struct NOT_POSITIVE end
is_positive(::AbstractImage2DModel) = NOT_POSITIVE()

struct IS_NONNEGATIVE end
struct NOT_NONNEGATIVE end
is_nonnegative(::AbstractImage2DModel) = NOT_NONNEGATIVE()

function AbstractImage2DModel(Image2DModelType, image::EHTImages.AbstractEHTImage, idx=[1, 1, 1])
    nx, ny, _ = size(image)
    dx = image.metadata[:dx]
    dy = image.metadata[:dy]
    ixref = image.metadata[:ixref]
    iyref = image.metadata[:iyref]
    orgidx = idx
    pulsetype = Symbol(image.metadata[:pulsetype])
    return Image2DModelType((nx, ny), (dx, dy), (ixref, iyref), pulsetype, orgidx)
end

function totalflux(imagemodel::AbstractImage2DModel, x::AbstractArray)
    x_linear = transform_linear_forward(imagemodel, x)
    return sum(x_linear)
end

function normalize(imagemodel::AbstractImage2DModel, x::AbstractArray, totalflux=1.0)
    x_linear = transform_linear_forward(imagemodel, x)
    x_totalflux = sum(x_linear)
    x_norm = x_linear * totalflux / x_totalflux
    return transform_linear_inverse(imagemodel, x_norm)
end

function Base.map(image::EHTImages.AbstractEHTImage, imagemodel::AbstractImage2DModel, x::AbstractArray)
    imageout = copy(image)
    map!(imageout, imagemodel, x)
    return imageout
end

function Base.map(image::EHTImages.AbstractEHTImage, imagemodel::AbstractImage2DModel, x::AbstractArray, idx)
    imageout = copy(image)
    map!(imageout, imagemodel, x, idx)
    return imageout
end

function Base.map!(image::EHTImages.AbstractEHTImage, imagemodel::AbstractImage2DModel, x::AbstractArray)
    map!(image, imagemodel, x, imagemodel.orgidx)
end

function Base.map!(image::EHTImages.AbstractEHTImage, imagemodel::AbstractImage2DModel, x::AbstractArray, idx)
    x_linear = transform_linear_forward(imagemodel, x)
    setindex!(image.data, x_linear, :, :, idx...)
end