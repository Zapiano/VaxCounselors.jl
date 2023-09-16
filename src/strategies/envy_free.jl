using ..SimplexTools

function run_envy_free(
	timestamp::Int64,
	country::String,
	utility::Int64,
	N::Int64,
	V::Int64,
)::Nothing
	# Build utilities
	utility_A, utility_B = UtilityFunction.build_utilities(country, utility)

	# TODO uncomment this
	#VaxCounselors.writeUtilityDensityCSV(utility_A, utility_B, timestamp, country, utility)

	#TODO allow passing d as argument
	divisions::Int64 = 99

	#Run model
	iteration = 0
	unvaccinated_population::Int64 = N
	vaccinated_intervals::Vector{Vector{Float64}} = []

	envy_free_points::Vector{EFPoint} = []

	while unvaccinated_population > 0
		vaccines_fraction::Float64 = V / unvaccinated_population

		if vaccines_fraction >= 1
			vaccinated_intervals = [[0.0, 1.0]]
		else
			simplex = SimplexTools.Simplex(divisions, vaccines_fraction, utility_A, utility_B)
			ef_point = SimplexTools.EFPoint(simplex, utility_A, utility_B)
			vaccinated_intervals = ef_point.vaccinationIntervals
			push!(envy_free_points, ef_point)

			#* Iterative Plot
			#TODO turn log option through a parameter iterativePlot=True/False
			# plotIterative(utility_A, utility_B, ef_point, iteration)
		end

		UtilityFunction.update_utility!(utility_A, vaccinated_intervals)
		UtilityFunction.update_utility!(utility_B, vaccinated_intervals)

		unvaccinated_population -= V
		iteration += 1
	end

	#TODO writeVaccinatedPopulationCSV

	#TODO turn log option through a parameter log=True/False
	# logEnvy_free_points(envy_free_points,timestamp,country,utility)

	idx_strategy::Int64 = 1
	VaxCounselors.write_benefits_CSV(
		utility_A.benefits,
		utility_B.benefits,
		idx_strategy,
		timestamp,
		country,
		utility,
	)

	return nothing
end
