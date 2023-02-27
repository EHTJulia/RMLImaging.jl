export Imager2D
export ImagingProblem

struct Imager2D <: AbstractImager
    skymodel::AbstractImage2DModel
    ft::SingleNFFT2D
    datamodels
    regularlizers
end

function ImagingProblem(imager::Imager2D, x0::AbstractArray)
    # define optimization function
    optfunc = OptimizationFunction(lossfunc, Optimization.AutoZygote())

    # define optimization problem
    optprob = Optimization.OptimizationProblem(optfunc, x0, imager)

    return optprob
end

function lossfunc(x, imager::Imager2D)
    # get the linear scale image
    x_linear = transform_linear_forward(imager.skymodel, x)

    # Get the Stokes I image
    V = forward(imager.ft, x_linear)

    # Initialize cost function
    c = 0

    # Chisquares
    for datamodel in imager.datamodels
        c += chisquare(datamodel, V)
    end

    # Regularization functions
    for reg in imager.regularlizers
        c += cost(reg, imager.skymodel, x)
    end

    return c
end

"""
    map(image::EHTImages.AbstractEHTImage, imager::Imager2D, x::AbstractArray[, idx])
"""
function Base.map(image::EHTImages.AbstractEHTImage, imager::Imager2D, x::AbstractArray)
    return map(image, imager.skymodel, x)
end

function Base.map(image::EHTImages.AbstractEHTImage, imager::Imager2D, x::AbstractArray, idx)
    return map(image, imager.skymodel, x, idx)
end

"""
    map!(image::EHTImages.AbstractEHTImage, imager::Imager2D, x::AbstractArray[, idx])
"""
function Base.map!(image::EHTImages.AbstractEHTImage, imager::Imager2D, x::AbstractArray)
    map!(image, imager.skymodel, x)
end

function Base.map!(image::EHTImages.AbstractEHTImage, imager::Imager2D, x::AbstractArray, idx)
    map!(image, imager.skymodel, x, idx)
end