function vaccinated_population(
    vaccinated_population::NamedDimsArray;
    country=:usa,
    label_letters=false,
    lang=:en,
    axis_opts::Dict=Dict(),
    fig_opts::Dict=Dict(),
)
    resolution = get(fig_opts, :resolution, (800, 600))
    f = Figure(; resolution=resolution)

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
            theme = get(axis_opts, :theme, :darkgrid)
            bg_color = THEME[theme].backgroundcolor
            grid_color = THEME[theme].gridcolor
            grid_width = THEME[theme].gridwidth

            Axis(
                f[row, col];
                backgroundcolor=bg_color,
                xgridcolor=grid_color,
                xgridwidth=grid_width,
                ygridcolor=grid_color,
                ygridwidth=grid_width,
                rightspinevisible=false,
                leftspinevisible=false,
                topspinevisible=false,
                bottomspinevisible=false,
                title=subtitle,
                titlesize=FONTS.title_size,
                titlefont=FONTS.family,
                xlabel=AXIS[lang].timesteps,
                xlabelsize=FONTS.axes_label_size,
                xlabelfont=FONTS.family,
                ylabel=AXIS[lang].population_frac,
                ylabelsize=FONTS.axes_label_size,
                ylabelfont=FONTS.family,
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
