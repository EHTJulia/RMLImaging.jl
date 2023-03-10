export chisquare
export evaluate
export initialize_datamodels
export residual
export VisibilityDataModel


struct VisibilityDataModel <: AbstractDataModel
    data
    σ
    variance
    designmatrix
    weight
    Ndata
end

# Function Label
functionlabel(::VisibilityDataModel) = :visibility

# Evaluate
function evaluate(datamodel::VisibilityDataModel, V::Vector{ComplexF64}; keywords...)
    return @inbounds getindex(V, datamodel.designmatrix)
end

# residual
function residual(datamodel::VisibilityDataModel, V::Vector{ComplexF64}; keywords...)
    model = evaluate(datamodel, V)
    @inbounds resid = (model .- datamodel.data) ./ datamodel.σ
    return resid
end

# chisquare
function chisquare(datamodel::VisibilityDataModel, V::Vector{ComplexF64}; keywords...)
    model = evaluate(datamodel, V)
    @inbounds sqresid = abs.(model .- datamodel.data) .^ 2 ./ datamodel.variance
    return sum(sqresid) / datamodel.Ndata
end

function get_stokesI(visds::DimStack; keywords...)
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

function visds2df(visds::DimStack; keywords...)
    # get data size
    nch, nspw, ndata, npol = size(visds)
    nvis = nch * nspw * ndata * npol

    # initialize dataframe
    df = DataFrame()
    df[!, :u] = zeros(Float64, nvis)
    df[!, :v] = zeros(Float64, nvis)
    df[!, :Vcmp] = zeros(ComplexF64, nvis)
    df[!, :σ] = zeros(Float64, nvis)
    df[!, :σ2] = zeros(Float64, nvis)
    df[!, :flag] = zeros(Float64, nvis)

    # fill out dataframe
    i = 1
    for ipol in 1:npol, idata in 1:ndata, ispw in 1:nspw, ich in 1:nch
        idx = (idata, ispw, ich, 1)
        df[i, :u] = visds[:u].data[ich, ispw, idata]
        df[i, :v] = visds[:v].data[ich, ispw, idata]
        df[i, :Vcmp] = visds[:visibility].data[ich, ispw, idata, ipol]
        df[i, :σ] = visds[:sigma].data[ich, ispw, idata, ipol]
        df[i, :σ2] = visds[:sigma].data[ich, ispw, idata, ipol]^2
        df[i, :flag] = visds[:flag].data[ich, ispw, idata, ipol]
        i += 1
    end

    # remove flagged data
    df = df[df.flag.>0, :]
    df = df[df.σ.>0, :]

    return df
end

function initialize_datamodels(df::DataFrame; keywords...)
    uv = df.u .+ 1im .* df.v
    uvc, reverse_idx = unique_ids(uv)
    uvcov = SingleUVCoverage(real(uvc), imag(uvc), reverse_idx)
    visdatamodel = VisibilityDataModel(
        df.Vcmp,
        df.σ,
        df.σ2,
        reverse_idx,
        1,
        length(df.Vcmp)
    )
    return uvcov, visdatamodel
end

function initialize_datamodels(visds::DimStack; keywords...)
    ds = get_stokesI(visds)
    df = visds2df(ds)
    uvcov, visdatamodel = initialize_datamodels(df)
    return uvcov, visdatamodel
end