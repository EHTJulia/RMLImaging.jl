export LogImage2DModel

# Definition of the model
struct LogImage2DModel <: AbstractImage2DModel
    imagesize
    pixelsize
    refpixel
    pulsetype
    orgidx
end

is_positive_image(::LinearImage2DModel) = IS_POSITIVE()
is_nonnegative_image(::LinearImage2DModel) = IS_NONNEGATIVE()

# Constructors
function LogImage2DModel(image::EHTImages.AbstractEHTImage, idx=[1, 1, 1])
    AbstractImage2DModel(LogImage2DModel, image, idx)
end

# Transoformer to linear-scale images
@inline transform_linear_forward(::LogImage2DModel, x::AbstractArray) = @inbounds exp.(x)

# Transformer from linear-scale images
@inline transform_linear_inverse(::LogImage2DModel, x::AbstractArray) = @inbounds log.(abs.(real(x)))

# Initialization
function initialize(imagemodel::LogImage2DModel, totalflux::Number=1.0)
    x = zeros(imagemodel.imagesize)
    return normalize(imagemodel, x, totalflux)
end

function initialize(imagemodel::LogImage2DModel, image::EHTImages.AbstractEHTImage)
    x_linear = getindex(image.data, :, :, imagemodel.orgidx...)
    return transform_linear_inverse(imagemodel, x_linear)
end

function initialize(imagemodel::LogImage2DModel, image::EHTImages.AbstractEHTImage, idx)
    x_linear = getindex(image.data, :, :, idx...)
    return transform_linear_inverse(imagemodel, x_linear)
end