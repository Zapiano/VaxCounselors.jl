module Strategies

using ..UtilityFunction
using VaxCounselors

include("maximize_benefit.jl")
include("minimize_benefit.jl")
include("oldest_first.jl")
include("random_vaccination.jl")
end