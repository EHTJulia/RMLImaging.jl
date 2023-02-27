export unique_ids

function unique_ids(itr)
    v = Vector{eltype(itr)}()
    d = Dict{eltype(itr),Int}()
    revid = Vector{Int}()
    for val in itr
        if haskey(d, val)
            push!(revid, d[val])
        else
            push!(v, val)
            d[val] = length(v)
            push!(revid, length(v))
        end
    end
    (v, revid)
end