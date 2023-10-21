function utility_densities(
    utilities::NamedDimsArray;
    country=:usa,
    label_letters=false,
    lang=:en,
    axis_opts::Dict=Dict(),
)
    f = Figure()

    # 3-dimensional NamedDimsArray
    _utilities = utilities[:, :, :, Key(country)]
    setup_keys = sort(Symbol.(get_axiskeys(_utilities, :setups)))
    sort!(setup_keys; by=x -> LABELS_LETTERS[:setups][x])
    setup_labels = label_letters ? LABELS_LETTERS.setups : LABELS[lang].setups

    y_low, y_high = get_y_limits(_utilities)
    n_population = size(_utilities, 1)
    xticks = (range(1, n_population; length=6), ["0", "0.2", "0.4", "0.6", "0.8", "1"])
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

            ax = Axis(
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
                xticks=xticks,
                title=subtitle,
                titlesize=FONTS.title_size,
                titlefont=:regular,
                xlabel=AXIS[lang].population,
                xlabelsize=FONTS.axes_label_size,
                ylabel=AXIS[lang].utility,
                ylabelsize=FONTS.axes_label_size,
                limits=(nothing, (y_low, y_high)),
            )

            timesteps = get_axiskeys(_utilities, :timesteps)
            benefits_A = collect(_utilities[:, Key(:A), Key(setup)])
            benefits_B = collect(_utilities[:, Key(:B), Key(setup)])
            benefits_mean = collect(_utilities[:, Key(:mean), Key(setup)])

            lines!(
                ax,
                timesteps,
                benefits_A;
                color=COLORS.counselors_utilities.A,
                linewidth=ELEMENTS.line_width,
            )
            lines!(
                ax,
                timesteps,
                benefits_B;
                color=COLORS.counselors_utilities.B,
                linewidth=ELEMENTS.line_width,
            )
            lines!(
                ax,
                timesteps,
                benefits_mean;
                color=COLORS.counselors_utilities.mean,
                linewidth=ELEMENTS.line_width,
            )
        end
    end

    _render_utilities_legend!(f, lang)

    return f
end

function _render_utilities_legend!(f, lang)::Nothing
    line_elements = [
        LineElement(; color=COLORS.counselors_utilities[c], linestyle=nothing) for
        c in [:A, :B, :mean]
    ]
    _labels = LABELS[lang].counselors
    Legend(
        f[1:end, 3],
        line_elements,
        [_labels.A, _labels.B, _labels.mean];
        linewidth=ELEMENTS.legend_line_width,
        labelsize=FONTS.legend_label_size,
        framevisible=false,
        rowgap=5,
    )
    return nothing
end
