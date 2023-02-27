export LinearImage2DModel

struct LinearImage2DModel <: AbstractImage2DModel
    imagesize
    pixelsize
    refpixel
    pulsetype
    orgidx
end

is_positive(::LinearImage2DModel) = NOT_POSITIVE()
is_nonnegative(::LinearImage2DModel) = NOT_NONNEGATIVE()

function LinearImage2DModel(image::EHTImages.AbstractEHTImage, idx=[1, 1, 1])
    AbstractImage2DModel(LinearImage2DModel, image, idx)
end

function transform_linear_forward(imagemodel::LinearImage2DModel, x::AbstractArray)
    return x
end

function transform_linear_inverse(imagemodel::LinearImage2DModel, x::AbstractArray)
    return x
end

function initialize(imagemodel::LinearImage2DModel)
    return zeros(imagemodel.imagesize)
end

function initialize(imagemodel::LinearImage2DModel, value::Number)
    return fill(value, imagemodel.imagesize)
end

function initialize(imagemodel::LinearImage2DModel, image::EHTImages.AbstractEHTImage)
    return getindex(image.data, :, :, imagemodel.orgidx...)
end

function initialize(imagemodel::LinearImage2DModel, image::EHTImages.AbstractEHTImage, idx)
    return getindex(image.data, :, :, idx...)
end