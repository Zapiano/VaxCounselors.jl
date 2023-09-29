module Viz

using CairoMakie
using CSV
using NamedDims
using AxisKeys

function get_data(data_folder::String)::NamedDimsArray
    data_folder = df
    countries = readdir(data_folder)
    setups = readdir("$(data_folder)/$(countries[1])")
    benefit_files = filter(
        x -> split(x, "__")[1] == "benefit",
        readdir("$(data_folder)/$(countries[1])/$(setups[1])"),
    )

    strategies = [split(split(s, "__")[2], ".")[1] for s in benefit_files]
    counselors = [:A, :B]

    tmp_file = CSV.File(
        open("$(data_folder)/$(countries[1])/$(setups[1])/$(benefit_files[1])")
    )
    n_timesteps = length(tmp_file)
    n_counselors = length(counselors)
    n_strategies = length(strategies)
    n_setups = length(setups)
    n_countries = length(countries)

    data = NamedDimsArray(
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
                data[:, Key(:A), Key(strategy), Key(setup), Key(country)] = benefit_csv[:A]
                data[:, Key(:B), Key(strategy), Key(setup), Key(country)] = benefit_csv[:B]
            end
        end
    end
    return data
end

end
