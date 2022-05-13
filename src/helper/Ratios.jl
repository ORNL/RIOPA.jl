function Base.parse(::Type{Rational{Int32}}, x::AbstractString)
    ms, ns = split(x, '/', keepempty = false)
    m = parse(Int32, ms)
    n = parse(Int32, ns)
    return m // n
end

Base.parse(::Type{Rational}, x::AbstractString) = parse(Rational{Int32}, x)

function get_ratio(x::AbstractString)
    r = tryparse(Float64, x)
    return r === nothing ? convert(Float64, parse(Rational, x)) : r
end

get_ratio(x::Float64) = x
