using ..SimplexTools

function run_envy_free(
    timestamp::Int64, country::String, setup::Symbol, N::Int64, V::Int64
)::Nothing
    utility_A, utility_B = UtilityFunction.build_utilities(country, setup)

    VaxCounselors.write_utility_density_CSV(utility_A, utility_B, timestamp, country, setup)

    #TODO allow passing d as argument
    divisions::Int64 = 99

    # Set parameters to run model
    iteration::Int64 = 0
    unvaccinated_population::Int64 = N
    vaccinated_intervals::Vector{Vector{Float64}} = []

    while unvaccinated_population > 0
        vaccines_fraction::Float64 = V / unvaccinated_population

        if vaccines_fraction >= 1
            vaccinated_intervals = [[0.0, 1.0]]
        else
            simplex::Simplex = SimplexTools.Simplex(
                divisions, vaccines_fraction, utility_A, utility_B
            )
            ef_point::EFPoint = SimplexTools.EFPoint(simplex, utility_A, utility_B)
            vaccinated_intervals = ef_point.vaccinationIntervals

            #TODO iterative_plot(utility_A, utility_B, ef_point, iteration)
        end

        UtilityFunction.update_utility!(utility_A, vaccinated_intervals)
        UtilityFunction.update_utility!(utility_B, vaccinated_intervals)

        unvaccinated_population -= V
        iteration += 1
    end

    VaxCounselors.write_vaccinated_population_CSV(
        utility_A.vaccinated_population, :envy_free, timestamp, country, setup
    )

    VaxCounselors.write_benefits_CSV(
        utility_A.benefits, utility_B.benefits, :envy_free, timestamp, country, setup
    )

    return nothing
end
