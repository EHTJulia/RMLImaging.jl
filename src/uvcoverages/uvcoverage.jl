export SingleUVCoverage

"""
    SingleUVCoverage(u, v, reverse_idx) <: AbstractUVCoverage

A basic type for single uv-coverage.

# Arguemnts:
- `u::Vector`
- `v::Vector`
- `reverse_idx::Vector`
"""
struct SingleUVCoverage <: AbstractUVCoverage
    u::Vector
    v::Vector
    reverse_idx::Vector
end

function SingleUVCoverage(u::Vector, v::Vector)::SingleUVCoverage
    uvc, idx = unique_ids(u .+ 1im .* v)
    return SingleUVCoverage(real(uvc), imag(uvc), idx)
end