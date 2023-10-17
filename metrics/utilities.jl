function utilities(data_folder::String)::NamedDimsArray
    countries = Symbol.(filter(x -> x[1] != '.', readdir(data_folder)))
    setups = Symbol.(readdir("$(data_folder)/$(countries[1])"))
    utility_file = "utility_density"
    counselors = [:A, :B, :mean]

    tmp_file = CSV.File(
        open("$(data_folder)/$(countries[1])/$(setups[1])/$(utility_file).csv")
    )
    n_timesteps = length(tmp_file)
    n_counselors = length(counselors)
    n_setups = length(setups)
    n_countries = length(countries)

    utilities = NamedDimsArray(
        zeros(n_timesteps, n_counselors, n_setups, n_countries);
        timesteps=1:n_timesteps,
        counselors=counselors,
        setups=setups,
        countries=countries,
    )

    for country in countries, setup in setups
        utility_path = "$(data_folder)/$(country)/$(setup)/$(utility_file).csv"
        utility_csv = CSV.File(open(utility_path))
        utilities[:, Key(:A), Key(setup), Key(country)] = utility_csv[:A]
        utilities[:, Key(:B), Key(setup), Key(country)] = utility_csv[:B]
        utilities[:, Key(:mean), Key(setup), Key(country)] = utility_csv[:mean]
    end
    return utilities
end
