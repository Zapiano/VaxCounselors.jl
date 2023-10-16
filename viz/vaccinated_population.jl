using AxisKeys
using CairoMakie
using NamedDims
using LaTeXStrings

function get_vaccinated_population(data_folder::String, countries=[:usa])::NamedDimsArray
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

function vaccinated_population(
    vaccinated_population::NamedDimsArray; country=:usa, label_letters=false, lang=:en
)
    f = Figure()

    # 3-dimensional NamedDimsArray
    vax_pop = vaccinated_population[:, :, :, Key(country)]

    setup_keys = axiskeys(vax_pop)[dim(vax_pop, :setups)]
    sort!(setup_keys; by=x -> LABELS_LETTERS[:setups][x])
    setup_labels = label_letters ? LABELS_LETTERS.setups : LABELS[lang].setups

    y_low, y_high = get_y_limits(vax_pop)

    n_figures = length(setup_keys)
    n_cols, n_rows = get_cols_rows(n_figures)

    for col in 1:n_cols, row in 1:n_rows
        index = col + n_cols * (row - 1)

        if index <= n_figures
            setup = setup_keys[index]
            subtitle = setup_labels[setup]
            Axis(
                f[row, col];
                title=subtitle,
                xlabel=AXIS[lang].timesteps,
                ylabel=AXIS[lang].population_frac,
                #yticks=([0, 0.25, 0.5, 0.75, 1], ["0%", "25%", "50%", "75%", "100%"]),
                limits=(nothing, (y_low, y_high)),
            )
            colors = collect(values(COLORS.age_groups))
            series!(vax_pop[:, :, Key(setup)]'; color=colors)
        end
    end

    #_render_vax_pop_legend!(f, lang)

    return f
end

#function _render_vax_pop_legend!(f, lang)::Nothing
#    line_elements = [
#        LineElement(; color=COLORS.counselors[c], linestyle=nothing) for
#        c in [:A, :B, :mean]
#    ]
#    _labels = LABELS[lang].counselors
#    Legend(
#        f[1:end, 3],
#        line_elements,
#        [_labels.A, _labels.B, _labels.mean];
#        framevisible=false,
#        rowgap=5,
#    )
#    return nothing
#end
