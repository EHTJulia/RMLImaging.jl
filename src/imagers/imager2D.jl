export Imager2D
export ImagingProblem

struct Imager2D <: AbstractImager
    skymodel::AbstractImage2DModel
    ft::SingleNFFT2D
    datamodels
    regularlizers
end

"""
    ImagingProblem(imager::Imager2D, x0::AbstractArray)

Initialize Optimization.OptimizationProblem for RML Imaging.
Returns the initialized Optimization.OptimizationProblem object.

# Arguments
- `imager::Imager2D`: the imager
- `x0::AbstractArray`: the initial image in the parameter domain.
"""
function ImagingProblem(imager::Imager2D, x0::AbstractArray)
    # define optimization function
    optfunc = OptimizationFunction(lossfunc, Optimization.AutoZygote())

    # define optimization problem
    optprob = Optimization.OptimizationProblem(optfunc, x0, imager)

    return optprob
end


"""
    ImagingProblem(imager::Imager2D, initialimage::AbstractEHTImage)

Initialize Optimization.OptimizationProblem for RML Imaging.
Returns the initialized Optimization.OptimizationProblem object.

# Arguments
- `imager::Imager2D`: the imager
- `x0::AbstractArray`: the initial image in the parameter domain.
"""
function ImagingProblem(imager::Imager2D, initimage::AbstractEHTImage)
    x0 = initialize(imager.skymodel, initimage)
    return ImagingProblem(imager::Imager2D, x0::AbstractArray)
end


"""
    lossfunc(x, imager::Imager2D)

The Loss function for the basic 2-dimensional RML Imaging problem.
Returns the cost function.

# Arguments
- `x::AbstractArray`: the image parameters
- `imager::Imager2D`: RML Imaging Setting
"""
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
    evaluate(imager::Imager2D, image::AbstractEHTImage)

Evaluate chisquares and regularizers from the input image

# Arguments
- `imager::Imager2D`: RML Imaging Setting
- `image::AbstractEHTImage`: the image
"""
function evaluate(imager::Imager2D, image::AbstractEHTImage)
    return evaluate(imager, initialize(imager.skymodel, image))
end

"""
    evaluate(imager::Imager2D, x::AbstractArray)

Evaluate chisquares and regularizers from the input image parameters

# Arguments
- `imager::Imager2D`: RML Imaging Setting
- `x::AbstractArray`: the image parameters
"""
function evaluate(imager::Imager2D, x::AbstractArray)
    # get the linear scale image
    x_linear = transform_linear_forward(imager.skymodel, x)

    # Get the Stokes I image
    V = forward(imager.ft, x_linear)

    # initialize dict
    outdict = OrderedDict()

    # Initialize cost function
    c = 0

    # Chisquares
    for datamodel in imager.datamodels
        chisq = chisquare(datamodel, V)
        outdict[functionlabel(datamodel)] = chisq
        c += chisq
    end

    # Regularization functions
    for reg in imager.regularlizers
        regcost = cost(reg, imager.skymodel, x)
        outdict[functionlabel(reg)] = regcost
        c += regcost
    end

    outdict[:cost] = c
    return outdict
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

function Base.map(image::EHTImages.AbstractEHTImage, imager::Imager2D, solution::Optimization.SciMLBase.OptimizationSolution)
    return map(image, imager.skymodel, solution.u)
end

function Base.map(image::EHTImages.AbstractEHTImage, imager::Imager2D, solution::Optimization.SciMLBase.OptimizationSolution, idx)
    return map(image, imager.skymodel, solution.u, idx)
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

function Base.map!(image::EHTImages.AbstractEHTImage, imager::Imager2D, solution::Optimization.SciMLBase.OptimizationSolution)
    map!(image, imager.skymodel, solution.u)
end

function Base.map!(image::EHTImages.AbstractEHTImage, imager::Imager2D, solution::Optimization.SciMLBase.OptimizationSolution, idx)
    map!(image, imager.skymodel, solution.u, idx)
end