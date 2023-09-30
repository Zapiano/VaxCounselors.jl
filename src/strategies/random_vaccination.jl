function run_random_vaccination(
    timestamp::Int64, country::String, setup::Symbol, N::Int64, V::Int64
)::Nothing
    #TODO set seed

    # Build utilities
    utility_A, utility_B = UtilityFunction.build_utilities(country, setup)

    #Run model
    iteration::Int64 = 0
    unvaccinated_population::Int64 = N
    vaccinated_interval::Vector{Vector{Float64}} = []
    while unvaccinated_population > 0
        vaccines_fraction::Float64 = V / unvaccinated_population
        interval_start::Float64 = (1.0 - vaccines_fraction) * rand(Float64)
        interval_end::Float64 = interval_start + vaccines_fraction

        if vaccines_fraction >= 1
            vaccinated_interval = [[0.0, 1.0]]
        else
            vaccinated_interval = [[interval_start, interval_end]]
        end

        UtilityFunction.update_utility!(utility_A, vaccinated_interval)
        UtilityFunction.update_utility!(utility_B, vaccinated_interval)

        unvaccinated_population -= V
        iteration += 1
    end

    idx_strategy::Int64 = 4
    VaxCounselors.write_benefits_CSV(
        utility_A.benefits, utility_B.benefits, idx_strategy, timestamp, country, setup
    )

    return nothing
end
