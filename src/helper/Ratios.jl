"""
```jldoctest
julia> parse(Rational{Int}, "1/4")
1//4
julia> parse(Rational, "1//4")
1//4
```
"""
function Base.parse(::Type{Rational{T}}, x::AbstractString) where {T <: Integer}
    ms, ns = split(x, '/', keepempty = false)
    m = parse(T, ms)
    n = parse(T, ns)
    return m // n
end

Base.parse(::Type{Rational}, x::AbstractString) = parse(Rational{Int32}, x)

"""
    get_ratio(x::AbstractString)

Parse x as either a Float64 or a Rational and return a Float64 ratio.

```jldoctest
julia> get_ratio("1/4")
0.25
julia> get_ratio("0.5")
0.5
```
"""
function get_ratio(x::AbstractString)
    r = tryparse(Float64, x)
    return r === nothing ? convert(Float64, parse(Rational, x)) : r
end

"""
    get_ratio(x::Float64)

For Float64, simply returns x.

```jldoctest
julia> get_ratio(0.8)
0.8
```
"""
get_ratio(x::Float64) = x
