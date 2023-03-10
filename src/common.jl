function sum_floop(x::AbstractArray; ex=ThreadedEx())
    value = 0.0
    @floop ex for i in 1:length(x)
        @reduce value += x[i]
    end
    return value
end

function sum_floop_grad(x::AbstractArray)
    return ones(size(x)...)
end

function ChainRulesCore.rrule(::typeof(sum_floop), x::AbstractArray; ex=ThreadedEx())
    y = sum_floop(x; ex=ex)
    function pullback(Δy)
        f̄bar = NoTangent()
        xbar = @thunk(sum_floop_grad(x) .* Δy)
        exbar = NoTangent()
        return f̄bar, xbar, exbar
    end
    return y, pullback
end