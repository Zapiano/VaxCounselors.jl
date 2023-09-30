module Viz

include("./theme.jl")

using CairoMakie
using CSV
using NamedDims
using AxisKeys

function get_benefits(data_folder::String)::NamedDimsArray
    countries = Symbol.(readdir(data_folder))
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

function plot_benefits(benefits::NamedDimsArray; country=:usa, setup=:default)
    f = Figure()

    # 3-dimensional NamedDimsArray
    _benefits = benefits[:, :, :, Key(setup), Key(country)]
    strategies_keys = sort(Symbol.(_get_axiskeys(_benefits, :strategies)))
    sort!(strategies_keys; by=x -> LABELS_LETTERS[:strategies][x])
    strategies_labels = LABELS_LETTERS.strategies

    y_low, y_high = get_y_limits(_benefits)

    n_figures = length(strategies_keys)
    n_cols, n_rows = get_cols_rows(n_figures)

    for col in 1:n_cols, row in 1:n_rows
        index = col + n_cols * (row - 1)

        if index <= n_figures
            strategy = strategies_keys[index]
            subtitle = strategies_labels[strategy]
            ax = Axis(
                f[row, col];
                title=subtitle,
                xlabel="Timesteps",
                ylabel="Benefit",
                limits=(nothing, (y_low, y_high)),
            )

            timesteps = _get_axiskeys(_benefits, :timesteps)
            benefits_A = collect(_benefits[:, Key(:A), Key(strategy)])
            benefits_B = collect(_benefits[:, Key(:B), Key(strategy)])
            benefits_mean = (benefits_A + benefits_B) / 2

            lines!(ax, timesteps, benefits_A; color=COLORS.counselors.A)
            lines!(ax, timesteps, benefits_B; color=COLORS.counselors.B)
            lines!(ax, timesteps, benefits_mean; color=COLORS.counselors.mean)
        end
    end

    return f
end

function _get_axiskeys(data::NamedDimsArray, dimname::Symbol)
    return axiskeys(data)[findall(x -> x == dimname, dimnames(data))][1]
end

function get_cols_rows(n_figures::Int64)::Tuple{Int64,Int64}
    return fldmod(n_figures, 2) .+ (0, 2)
end

function get_y_limits(data::AbstractArray)::Tuple{Float64,Float64}
    y_min, _ = findmin(data)
    y_max, _ = findmax(data)
    delta = (y_max - y_min) * 0.1
    return y_min - delta, y_max + delta
end
end
