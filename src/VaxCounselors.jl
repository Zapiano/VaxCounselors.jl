module VaxCounselors

using Dates

# Internal
include("./dicts/countries.jl")
include("./dicts/setups.jl")
include("./dicts/protocols.jl")
include("./dicts/demographicLabels.jl")

include("./misc/file_manager.jl")

include("utility_function/utility_function.jl")
include("utility_function/smooth_steps.jl")

include("strategies/strategies.jl")

function runModel(
	countries::Vector{String},
	setups::Vector{Int64} = 1,
)
	println("# Running Model\nCountries: $(countries)\nSetups: $(setups)")

	if length(countries) == 0
		countries = [String(k) for k in keys(COUNTRIES)]
	end

	timestamp::Int64 = _timestamp()

	for idx_c in countries
		for idx_s in setups
			folders_setup(timestamp, idx_c, idx_s)
			run_strategies(timestamp, idx_c, idx_s)
		end
	end

	#TODO write utilities csv
end

function run_strategies(
	timestamp::Int64,
	countryIndex::String,
	utilityIndex::Int64;
	N::Int64 = 10000,
	V::Int64 = 100,
)

	run_oldest_first(timestamp, countryIndex, utilityIndex, N, V)
	#runMaximizeUtility(timestamp, countryIndex, utilityIndex, N, V)
	#runMinimizeUtility(timestamp, countryIndex, utilityIndex, N, V)
	#runRandomVaccination(timestamp, countryIndex, utilityIndex, N, V)
	#runEnvyFree(timestamp, countryIndex, utilityIndex, N, V)

	#run(`say "Finish country $countryIndex and utility $utilityIndex"`)
end

function _timestamp()::Int64
	d = replace("$(Dates.now)", "-" => "", "T" => "", ":" => "")
	return parse(Int64, split(d, ".")[1])
end

end # module Vax
