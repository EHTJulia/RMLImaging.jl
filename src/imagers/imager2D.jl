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

