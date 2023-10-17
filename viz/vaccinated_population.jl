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
    n_timesteps = size(vax_pop, 1)

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
                yticks=(
                    range(y_low, y_high; length=5), ["0%", "25%", "50%", "75%", "100%"]
                ),
                xticks=(
                    range(0, n_timesteps; length=6), ["0", "20", "40", "60", "80", "100"]
                ),
                limits=(nothing, (y_low, y_high)),
            )
            colors = collect(values(COLORS.age_groups))
            series!(vax_pop[:, :, Key(setup)]'; color=colors)
        end
    end

    _render_vax_pop_legend!(f, lang)

    return f
end

function _render_vax_pop_legend!(f, lang)::Nothing
    line_elements = [LineElement(; color=c) for c in values(COLORS.age_groups)]
    _labels = collect(values(LABELS[lang].age_groups))
    #Main.@infiltrate
    Legend(f[1:end, 3], line_elements, _labels; framevisible=false, rowgap=5)
    return nothing
end
