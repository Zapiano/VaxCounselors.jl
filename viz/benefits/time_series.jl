function time_series(
    benefits::NamedDimsArray;
    country::Symbol=:usa,
    setup::Symbol=:default,
    strategies::Vector{Symbol}=Symbol[],
    label_letters::Bool=true,
    lang::Symbol=:en,
    cumulative::Bool=false,
    axis_opts::Dict=Dict(),
    fig_opts::Dict=Dict(),
)
    height = isempty(strategies) ? 850 : ceil(length(strategies) / 2) * 300
    resolution = get(fig_opts, :resolution, (800, height))
    f = Figure(; resolution=resolution)

    # 3-dimensional NamedDimsArray
    _benefits = if cumulative
        cumsum(benefits[:, :, :, Key(setup), Key(country)]; dims=1)
    else
        benefits[:, :, :, Key(setup), Key(country)]
    end

    strategies_keys = if !isempty(strategies)
        strategies
    else
        sort(Symbol.(get_axiskeys(_benefits, :strategies)))
    end
    sort!(strategies_keys; by=x -> LABELS_LETTERS[:strategies][x])
    strategies_labels = label_letters ? LABELS_LETTERS.strategies : LABELS[lang].strategies

    y_low, y_high = get_y_limits(_benefits)
    n_timesteps = size(benefits, 1)
    xticks = (range(1, n_timesteps; length=5), ["0", "25", "50", "75", "100"])

    n_figures = length(strategies_keys)
    n_cols, n_rows = get_cols_rows(n_figures)

    for col in 1:n_cols, row in 1:n_rows
        index = col + n_cols * (row - 1)

        if index <= n_figures
            strategy = strategies_keys[index]
            subtitle = strategies_labels[strategy]

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
                title=subtitle,
                titlesize=FONTS.title_size,
                titlefont=FONTS.family,
                xlabel=AXIS[lang].timesteps,
                xlabelsize=FONTS.axes_label_size,
                xlabelfont=FONTS.family,
                xticks=xticks,
                xticklabelfont=FONTS.family,
                ylabelfont=FONTS.family,
                ylabel=AXIS[lang].benefit,
                ylabelsize=FONTS.axes_label_size,
                yticklabelfont=FONTS.family,
                limits=(nothing, (y_low, y_high)),
            )

            timesteps = get_axiskeys(_benefits, :timesteps)
            benefits_A = collect(_benefits[:, Key(:A), Key(strategy)])
            benefits_B = collect(_benefits[:, Key(:B), Key(strategy)])
            benefits_mean = (benefits_A + benefits_B) / 2

            lines!(
                ax,
                timesteps,
                benefits_A;
                color=COLORS.counselors.A,
                linewidth=ELEMENTS.line_width,
            )
            lines!(
                ax,
                timesteps,
                benefits_B;
                color=COLORS.counselors.B,
                linewidth=ELEMENTS.line_width,
            )
            lines!(
                ax,
                timesteps,
                benefits_mean;
                color=COLORS.counselors.mean,
                linewidth=ELEMENTS.line_width,
            )
        end
    end

    _render_benefits_legend!(f, lang)

    return f
end

function _render_benefits_legend!(f, lang)::Nothing
    line_elements = [
        LineElement(; color=COLORS.counselors[c], linestyle=nothing) for
        c in [:A, :B, :mean]
    ]
    _labels = LABELS[lang].counselors
    Legend(
        f[end + 1, 1:end],
        line_elements,
        [_labels.A, _labels.B, _labels.mean];
        linewidth=ELEMENTS.legend_line_width,
        labelsize=FONTS.legend_label_size,
        labelfont=FONTS.family,
        framevisible=false,
        orientation=:horizontal,
    )
    return nothing
end
