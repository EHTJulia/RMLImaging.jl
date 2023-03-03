export chisquare
export evaluate
export initialize_datamodels
export residual
export VisibilityDataModel


struct VisibilityDataModel <: AbstractDataModel
    data
    σ
    designmatrix
    weight
    Ndata
end

functionlabel(::VisibilityDataModel) = :visibility

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

function get_stokesI(visds::DimStack)
    nch, nspw, ndata, npol = size(visds)

    # new visibility data set
    v = zeros(ComplexF64, nch, nspw, ndata, 1)
    σ = zeros(Float64, nch, nspw, ndata, 1)
    flag = zeros(Float64, nch, nspw, ndata, 1)

    for idata in 1:ndata, ispw in 1:nspw, ich in 1:nch
        v1 = visds[:visibility].data[ich, ispw, idata, 1]
        v2 = visds[:visibility].data[ich, ispw, idata, 2]
        f1 = visds[:flag].data[ich, ispw, idata, 1]
        f2 = visds[:flag].data[ich, ispw, idata, 2]
        σ1 = visds[:sigma].data[ich, ispw, idata, 1]
        σ2 = visds[:sigma].data[ich, ispw, idata, 2]

        if f1 <= 0 || f2 <= 0
            flag[ich, ispw, idata, 1] = -1
            continue
        else
            v[ich, ispw, idata, 1] = 0.5 * (v1 + v2)
            σ[ich, ispw, idata, 1] = 0.5 * √(σ1^2 + σ2^2)
            flag[ich, ispw, idata, 1] = 1
        end
    end

    c, s, d, p = dims(visds)
    newp = Dim{:p}([1])
    newplabel = ["I"]

    v = DimArray(data=v, dims=(c, s, d, newp), name=:visibility)
    σ = DimArray(data=σ, dims=(c, s, d, newp), name=:sigma)
    flag = DimArray(data=flag, dims=(c, s, d, newp), name=:flag)
    newplabel = DimArray(data=newplabel, dims=(newp), name=:polarization)

    newds = DimStack(
        v, σ, flag, newplabel,
        [visds[key] for key in keys(visds) if key ∉ [:visibility, :sigma, :flag, :polarization]]...
    )

    return newds
end

function visds2df(visds::DimStack)
    # get data size
    nch, nspw, ndata, npol = size(visds)
    nvis = nch * nspw * ndata * npol

    # initialize dataframe
    df = DataFrame()
    df[!, :u] = zeros(Float64, nvis)
    df[!, :v] = zeros(Float64, nvis)
    df[!, :Vcmp] = zeros(ComplexF64, nvis)
    df[!, :σ] = zeros(Float64, nvis)
    df[!, :flag] = zeros(Float64, nvis)

    # fill out dataframe
    i = 1
    for ipol in 1:npol, idata in 1:ndata, ispw in 1:nspw, ich in 1:nch
        idx = (idata, ispw, ich, 1)
        df[i, :u] = visds[:u].data[ich, ispw, idata]
        df[i, :v] = visds[:v].data[ich, ispw, idata]
        df[i, :Vcmp] = visds[:visibility].data[ich, ispw, idata, ipol]
        df[i, :σ] = visds[:sigma].data[ich, ispw, idata, ipol]
        df[i, :flag] = visds[:flag].data[ich, ispw, idata, ipol]
        i += 1
    end

    # remove flagged data
    df = df[df.flag.>0, :]
    df = df[df.σ.>0, :]

    return df
end

function initialize_datamodels(df::DataFrame)
    uv = df.u .+ 1im .* df.v
    uvc, reverse_idx = unique_ids(uv)
    uvcov = SingleUVCoverage(real(uvc), imag(uvc), reverse_idx)
    visdatamodel = VisibilityDataModel(
        df.Vcmp,
        df.σ,
        reverse_idx,
        1,
        length(df.Vcmp)
    )
    return uvcov, visdatamodel
end

function initialize_datamodels(visds::DimStack)
    ds = get_stokesI(visds)
    df = visds2df(ds)
    uvcov, visdatamodel = initialize_datamodels(df)
    return uvcov, visdatamodel
end