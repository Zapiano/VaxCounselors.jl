module Viz

using AxisKeys
using CairoMakie
using Colors
using ColorSchemes
using NamedDims

include("./theme.jl")

include("./benefits/summary.jl")
include("./benefits/time_average.jl")
include("./benefits/time_series.jl")
include("./utilities.jl")
include("vaccinated_population.jl")

function get_axiskeys(data::NamedDimsArray, dimname::Symbol)
    return axiskeys(data)[findall(x -> x == dimname, dimnames(data))][1]
end

function get_cols_rows(n_figures::Int64)::Tuple{Int64,Int64}
    return fldmod(n_figures, 2) .+ (0, 2)
end

function get_y_limits(data::AbstractArray)::Tuple{Float64,Float64}
    y_min, _ = findmin(data)
    y_max, _ = findmax(data)
    delta = (y_max - y_min) * 0.1
    return y_min - delta, y_max + delta
end
end
