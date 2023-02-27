export VisibilityDataModel
export evaluate
export residual
export chisquare

struct VisibilityDataModel <: AbstractDataModel
    data
    σ
    designmatrix
    weight
    Ndata
end

function evaluate(datamodel::VisibilityDataModel, V::Vector{ComplexF64})
    return getindex(V, datamodel.designmatrix)
end

function residual(datamodel::VisibilityDataModel, V::Vector{ComplexF64})
    model = evaluate(datamodel, V)
    return (model .- datamodel.data) ./ datamodel.σ
end

function chisquare(datamodel::VisibilityDataModel, V::Vector{ComplexF64})
    model = evaluate(datamodel, V)

    # variance
    var = datamodel.σ .^ 2

    # residual
    squaredresidual = abs.(model .- datamodel.data) .^ 2 ./ var

    return sum(squaredresidual) / datamodel.Ndata
end