function vaccinated_population(
    data_folder::String; countries::Vector{Symbol}=[:usa]
)::NamedDimsArray
    countries = if isempty(countries)
        Symbol.(filter(x -> x[1] != '.', readdir(data_folder)))
    else
        countries
    end

    country_path = joinpath(data_folder, "$(countries[1])")
    setups = Symbol.(readdir(country_path))

    vax_pop_file = "vaccinated_population__envy_free.csv"
    vax_pop_path = joinpath(country_path, "$(setups[1])", vax_pop_file)
    tmp_file = CSV.File(open(vax_pop_path))

    n_timesteps = length(tmp_file)
    timesteps = 1:n_timesteps

    age_groups = [:ag0_14, :ag15_24, :ag25_64, :ag_65]
    n_age_groups = length(age_groups)
    n_setups = length(setups)
    n_countries = length(countries)

    vax_pop = NamedDimsArray(
        zeros(n_timesteps, n_age_groups, n_setups, n_countries);
        timesteps=timesteps,
        age_groups=age_groups,
        setups=setups,
        countries=countries,
    )

    for country in countries
        for setup in setups
            vax_pop_path = joinpath(data_folder, "$country", "$setup", vax_pop_file)
            vax_pop_csv = CSV.File(open(vax_pop_path))

            for ag in age_groups
                vax_pop[:, Key(ag), Key(setup), Key(country)] = vax_pop_csv[ag]
            end
        end
    end

    return vax_pop
end
