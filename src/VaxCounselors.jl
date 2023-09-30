module VaxCounselors

using Dates
using Distributed
using ProgressMeter

# Internal
include("../dict/countries.jl")
include("../dict/setups.jl")
include("../dict/protocols.jl")
include("../dict/demographicLabels.jl")

include("utility_function/utility_function.jl")

include("../io/io.jl")

include("../viz/viz.jl")

include("simplex_tools.jl")
include("strategies/strategies.jl")

export run_model

"""
  function runModel(; countries::Vector{String} = [], setups::Vector{Int64} = 1)
"""
function run_model(countries::Vector{String}, setups::Vector{Symbol})::Nothing
    isempty(countries) && (countries = [String(k) for k in keys(COUNTRIES)])
    isempty(setups) && (setups = keys(SETUPS)[1:4])

    println("# Running Model\nCountries: $(countries)\nSetups: $(setups)")

    timestamp::Int64 = _timestamp()

    params_length = length(countries) * length(setups)
    timestamp_params::Vector{Int64} = zeros(Int64, params_length)
    countries_params::Vector{String} = Vector{String}(undef, params_length)
    setups_params::Vector{Symbol} = Vector{Symbol}(undef, params_length)

    for (idx_c, country) in enumerate(countries)
        for (idx_s, setup) in enumerate(setups)
            idx_param = length(countries) * (idx_s - 1) + idx_c

            timestamp_params[idx_param] = timestamp
            countries_params[idx_param] = country
            setups_params[idx_param] = setup

            folders_setup(timestamp, country, setup)
        end
    end

    @showprogress pmap(_run_strategies, timestamp_params, countries_params, setups_params)

    #TODO write utilities csv
    return nothing
end
function run_model(setups::Vector{Symbol})::Nothing
    return run_model(Vector{String}[], setups)
end
function run_model(countries_range::UnitRange{Int64}, setups::Vector{Symbol})::Nothing
    countries::Vector{String} = collect(keys(COUNTRIES))[countries_range]
    return run_model(countries, setups)
end

function _run_strategies(
    timestamp::Int64, country::String, setup::Symbol; N::Int64=10000, V::Int64=100
)
    Strategies.run_oldest_first(timestamp, country, setup, N, V)
    Strategies.run_maximize_benefit(timestamp, country, setup, N, V)
    Strategies.run_minimize_benefit(timestamp, country, setup, N, V)
    Strategies.run_random_vaccination(timestamp, country, setup, N, V)
    return Strategies.run_envy_free(timestamp, country, setup, N, V)

    #run(`say "Finish country $countryIndex and utility $utilityIndex"`)
end

function _timestamp()::Int64
    date = replace("$(Dates.now())", "-" => "", "T" => "", ":" => "")
    return parse(Int64, split(date, ".")[1])
end

end # module Vax
