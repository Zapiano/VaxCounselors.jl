#* Custom Modules
function run_oldest_first(
	timestamp::Int64,
	country::String,
	utility::Int64,
	N::Int64,
	V::Int64,
)
	println("""
		## Running Oldest First with parameters: 
		  country = $country,
		  utility = $utility,
		  N = $N,
		  V = $V
	""")

	# Build counselors utilities
	utilityA, utilityB = buildUtilities(country, utility)

	#Run model
	iteration = 0
	unvaccinatedPopulation = N
	while unvaccinatedPopulation > 0
		# Choose the oldest ones to be vaccinated
		delta::Float64 = V // unvaccinatedPopulation
		endPoint::Float64 = 1.0
		startPoint::Float64 = endPoint - delta
		vaccinatedInterval::Vector{Float64} = [startPoint, endPoint]

		lastIteration = (delta >= 1)
		if !lastIteration
			updateUtility!(utilityA, [vaccinatedInterval])
			updateUtility!(utilityB, [vaccinatedInterval])
		end

		unvaccinatedPopulation -= V
		iteration += 1
	end

	# Add last iteration benefit
	push!(utilityA.benefits, 1.0)
	push!(utilityB.benefits, 1.0)

	idx_strategy = 3
	writeBenefitCSV(utilityA.benefits,
		utilityB.benefits,
		idx_strategy,
		timestamp,
		country,
		utility)
end
