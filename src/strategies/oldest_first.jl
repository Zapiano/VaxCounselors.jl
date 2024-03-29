function run_oldest_first(
    timestamp::Int64, country::String, setup::Symbol, N::Int64, V::Int64
)::Nothing
    # Build counselors utilities
    utility_A, utility_B = UtilityFunction.build_utilities(country, setup)

    #Run model
    iteration::Int64 = 0
    unvaccinated_population::Int64 = N
    while unvaccinated_population > 0
        # Choose the oldest ones to be vaccinated
        delta::Float64 = V / unvaccinated_population
        end_point::Float64 = 1.0
        start_point::Float64 = end_point - delta
        vaccinated_interval::Vector{Float64} = [start_point, end_point]

        if (delta < 1)
            UtilityFunction.update_utility!(utility_A, [vaccinated_interval])
            UtilityFunction.update_utility!(utility_B, [vaccinated_interval])
        end

        unvaccinated_population -= V
        iteration += 1
    end

    # Add last iteration benefit
    push!(utility_A.benefits, 1.0)
    push!(utility_B.benefits, 1.0)

    VaxCounselors.write_benefits_CSV(
        utility_A.benefits, utility_B.benefits, :oldest_first, timestamp, country, setup
    )

    return nothing
end
