function benefits(data_folder::String)::NamedDimsArray
    countries = Symbol.(filter(x -> x[1] != '.', readdir(data_folder)))
    setups = Symbol.(readdir("$(data_folder)/$(countries[1])"))
    benefit_files = filter(
        x -> split(x, "__")[1] == "benefit",
        readdir("$(data_folder)/$(countries[1])/$(setups[1])"),
    )

    strategies = Symbol.([split(split(s, "__")[2], ".")[1] for s in benefit_files])
    counselors = [:A, :B]

    tmp_file = CSV.File(
        open("$(data_folder)/$(countries[1])/$(setups[1])/$(benefit_files[1])")
    )
    n_timesteps = length(tmp_file)
    n_counselors = length(counselors)
    n_strategies = length(strategies)
    n_setups = length(setups)
    n_countries = length(countries)

    benefits = NamedDimsArray(
        zeros(n_timesteps, n_counselors, n_strategies, n_setups, n_countries);
        timesteps=1:n_timesteps,
        counselors=counselors,
        strategies=strategies,
        setups=setups,
        countries=countries,
    )

    for country in countries
        for setup in setups
            for strategy in strategies
                # Get list of benefit datasets
                benefit_path = "$(data_folder)/$(country)/$(setup)/benefit__$(strategy).csv"
                benefit_csv = CSV.File(open(benefit_path))
                benefits[:, Key(:A), Key(strategy), Key(setup), Key(country)] = benefit_csv[:A]
                benefits[:, Key(:B), Key(strategy), Key(setup), Key(country)] = benefit_csv[:B]
            end
        end
    end

    return benefits
end

"""
    avg_benefit_ab_diff(benefits::NamedDimsArray; cumulative::Bool=false)::NamedDimsArray

3-D NamedDimsArray with the difference between A and B time (cumulative or not) averge
benefits for each strategy, setup and country (in that order).
"""
function avg_benefit_ab_diff(
    benefits::NamedDimsArray; cumulative::Bool=false
)::NamedDimsArray
    timedim = dim(benefits, :timesteps)

    _benefits = if cumulative
        cumsum(benefits[:, :, :, :, :]; dims=timedim)
    else
        benefits[:, :, :, :, :]
    end

    A_benefit = _benefits[:, Key(:A), :, :, :]
    B_benefit = _benefits[:, Key(:B), :, :, :]
    ab_diff = abs.(A_benefit .- B_benefit)

    n_timesteps = size(benefits, 1)

    return dropdims(sum(ab_diff; dims=timedim); dims=timedim) ./ n_timesteps
end

"""
    avg_mean_cum_benefit(benefits::NamedDimsArray)::NamedDimsArray

3-D NamedDimsArray with the time cumulative average mean benefit (the mean is over A and B
counselors) for each strategy, setup and country (in that order).
"""
function avg_cum_mean_benefit(benefits::NamedDimsArray)::NamedDimsArray
    timedim = dim(benefits, :timesteps)

    A_benefit = cumsum(benefits[:, Key(:A), :, :, :]; dims=timedim)
    B_benefit = cumsum(benefits[:, Key(:B), :, :, :]; dims=timedim)
    mean_benefit = (A_benefit .+ B_benefit) ./ 2

    n_timesteps = size(benefits, 1)

    return dropdims(sum(mean_benefit; dims=timedim); dims=timedim) ./ n_timesteps
end
