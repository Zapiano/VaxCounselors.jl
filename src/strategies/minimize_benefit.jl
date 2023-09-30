function run_minimize_benefit(
    timestamp::Int64, country::String, setup::Symbol, N::Int64, V::Int64
)::Nothing
    # Build utilities
    utility_A, utility_B = UtilityFunction.build_utilities(country, setup)
    avg_utility = UtilityFunction.average_utility(utility_A.steps, utility_B.steps)

    #Run model
    iteration::Int64 = 0
    unvaccinated_population::Int64 = N
    vaccinated_interval::Vector{Vector{Float64}} = []
    while unvaccinated_population > 0
        vaccines_fraction::Float64 = V / unvaccinated_population
        if vaccines_fraction >= 1
            vaccinated_interval = [[0.0, 1.0]]
        else
            avg_steps = avg_utility.steps
            vaccinated_interval = UtilityFunction.mini_max_intervals(
                avg_steps, 0.0, "II", vaccines_fraction, "minimum"
            )
        end

        UtilityFunction.update_utility!(utility_A, vaccinated_interval)
        UtilityFunction.update_utility!(utility_B, vaccinated_interval)
        UtilityFunction.update_utility!(avg_utility, vaccinated_interval)

        unvaccinated_population -= V
        iteration += 1
    end

    idx_strategy::Int64 = 5
    VaxCounselors.write_benefits_CSV(
        utility_A.benefits, utility_B.benefits, idx_strategy, timestamp, country, setup
    )

    return nothing
end
