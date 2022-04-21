function Base.parse(::Type{Rational{Int}}, x::AbstractString)
    ms, ns = split(x, '/', keepempty = false)
    m = parse(Int, ms)
    n = parse(Int, ns)
    return m // n
end

Base.parse(::Type{Rational}, x::AbstractString) = parse(Rational{Int}, x)

function get_ratio(x::AbstractString)
    r = tryparse(Float64, x)
    return r === nothing ? convert(Float64, parse(Rational, x)) : r
end

get_ratio(x::Float64) = x
