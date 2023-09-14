module VaxCounselors

using Dates

# Internal
include("./dicts/countries.jl")
include("./dicts/setups.jl")
include("./dicts/protocols.jl")
include("./dicts/demographicLabels.jl")

include("./misc/file_manager.jl")

include("utility_function/utility_function.jl")
include("simplex_tools.jl")
include("strategies/strategies.jl")

export run_model

"""
  function runModel(; countries::Vector{String} = [], setups::Vector{Int64} = 1)
"""
function run_model(countries::Vector{String} = [], setups::Vector{Int64} = [1])
	println("# Running Model\nCountries: $(countries)\nSetups: $(setups)")

	isempty(countries) && (countries = [String(k) for k in keys(COUNTRIES)])
	timestamp::Int64 = _timestamp()

	for idx_c in countries
		for idx_s in setups
			folders_setup(timestamp, idx_c, idx_s)
			_run_strategies(timestamp, idx_c, idx_s)
		end
	end

	#TODO write utilities csv
end

function _run_strategies(
	timestamp::Int64,
	country_index::String,
	utility_index::Int64;
	N::Int64 = 10000,
	V::Int64 = 100,
)

	Strategies.run_oldest_first(timestamp, country_index, utility_index, N, V)
	Strategies.run_maximize_benefit(timestamp, country_index, utility_index, N, V)
	Strategies.run_minimize_benefit(timestamp, country_index, utility_index, N, V)
	Strategies.run_random_vaccination(timestamp, country_index, utility_index, N, V)
	Strategies.run_envy_free(timestamp, country_index, utility_index, N, V)

	#run(`say "Finish country $countryIndex and utility $utilityIndex"`)
end

function _timestamp()::Int64
	date = replace("$(Dates.now())", "-" => "", "T" => "", ":" => "")
	return parse(Int64, split(date, ".")[1])
end

end # module Vax
