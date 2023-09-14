module Strategies

using VaxCounselors
using ..UtilityFunction

include("envy_free.jl")
include("maximize_benefit.jl")
include("minimize_benefit.jl")
include("oldest_first.jl")
include("random_vaccination.jl")
end