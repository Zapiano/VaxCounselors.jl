"""
    avg_benefit_ab_diff(
        avg_benefit_ab_diff::NamedDimsArray;
        countries::Vector{Symbol}=[:usa],
        setup::Symbol=:default,
        label_letters::Bool=false,
        lang::Symbol=:en,
        cumulative::Bool=false,
    )

Plots time average A-B benefit difference

# Arguments
- `avg_benefit_ab_diff` : Time average A-B benefit difference for each strategy, setup and
country;
- `countries` : Countries to plot
- `setup` : Setups to plot
- `label_letters` : Boolean to plot strategy as letters (true) or words (false). Defaults
to false
- `lang` : Language in which to plot. Defaults to english
- `cumulative` : If true, plot cumulative sum. If false, plot non-cumulative sum. Defaults
to false

"""
function avg_benefit_ab_diff(
    avg_benefit_ab_diff::NamedDimsArray;
    countries::Vector{Symbol}=[:usa],
    setup::Symbol=:default,
    label_letters::Bool=false,
    lang::Symbol=:en,
    cumulative::Bool=false,
    axis_opts::Dict=Dict(),
    fig_opts::Dict=Dict(),
)
    resolution = get(fig_opts, :resolution, (800, 450))
    f = Figure(; resolution=resolution)

    strategies_keys = reverse(STRATEGY_KEYS.time_average)
    strategies_labels = label_letters ? LABELS_LETTERS.strategies : LABELS[lang].strategies

    data_size = length(countries) * length(strategies_keys)
    category_data = zeros(data_size)
    category_labels = Array{String}(undef, data_size)

    # TODO: Sort out colors by country
    category_colors = Array{RGB}(undef, data_size)
    n_countries = length(countries)

    color_palette = cgrad(:nipy_spectral, n_countries; categorical=true)

    for (idx_s, strategy) in enumerate(strategies_keys)
        for (idx_c, country) in enumerate(countries)
            index = idx_c + length(countries) * (idx_s - 1)
            category_data[index] = avg_benefit_ab_diff[
                Key(strategy), Key(setup), Key(country)
            ]
            category_labels[index] = strategies_labels[strategy]
            category_colors[index] = color_palette[idx_c]
        end
    end

    theme = get(axis_opts, :theme, :darkgrid)
    bg_color = THEME[theme].backgroundcolor
    grid_color = THEME[theme].gridcolor
    grid_width = THEME[theme].gridwidth
    ax = Axis(
        f[1, 1];
        backgroundcolor=bg_color,
        xgridcolor=grid_color,
        xgridwidth=grid_width,
        ygridvisible=false,
        rightspinevisible=false,
        leftspinevisible=false,
        topspinevisible=false,
        bottomspinevisible=false,
        xlabelfont=FONTS.family,
        xlabelsize=FONTS.axes_label_size,
        xticklabelfont=FONTS.family,
        ylabelfont=FONTS.family,
        ylabelsize=FONTS.axes_label_size,
        yticklabelfont=FONTS.family,
    )

    xlabel = cumulative ? AXIS[lang].abcumdiff : AXIS[lang].abdiff

    rainclouds!(
        ax,
        category_labels,
        category_data;
        xlabel=xlabel,
        clouds=nothing,
        plot_boxplots=false,
        markersize=15,
        jitter_width=0.3,
        side_nudge=0.05,
        color=category_colors,
        orientation=:horizontal,
    )

    _render_average_benefits_legend!(f, color_palette, countries, lang)

    return f
end

function avg_cum_mean_benefit(
    avg_cum_mean_benefit::NamedDimsArray;
    countries::Vector{Symbol}=[:usa],
    setup::Symbol=:default,
    label_letters::Bool=false,
    lang::Symbol=:en,
    axis_opts::Dict=Dict(),
    fig_opts::Dict=Dict(),
)
    resolution = get(fig_opts, :resolution, (800, 450))
    f = Figure(; resolution=resolution)

    strategies_keys = reverse(STRATEGY_KEYS.time_average)
    strategies_labels = label_letters ? LABELS_LETTERS.strategies : LABELS[lang].strategies

    data_size = length(countries) * length(strategies_keys)
    category_data = zeros(data_size)
    category_labels = Array{String}(undef, data_size)

    category_colors = Array{RGB}(undef, data_size)
    n_countries = length(countries)

    color_palette = cgrad(:nipy_spectral, n_countries; categorical=true)

    for (idx_s, strategy) in enumerate(strategies_keys)
        for (idx_c, country) in enumerate(countries)
            index = idx_c + length(countries) * (idx_s - 1)

            category_data[index] = avg_cum_mean_benefit[
                Key(strategy), Key(setup), Key(country)
            ]
            category_labels[index] = strategies_labels[strategy]
            category_colors[index] = color_palette[idx_c]
        end
    end

    theme = get(axis_opts, :theme, :darkgrid)
    bg_color = THEME[theme].backgroundcolor
    grid_color = THEME[theme].gridcolor
    grid_width = THEME[theme].gridwidth
    ax = Axis(
        f[1, 1];
        backgroundcolor=bg_color,
        xgridcolor=grid_color,
        xgridwidth=grid_width,
        ygridvisible=false,
        rightspinevisible=false,
        leftspinevisible=false,
        topspinevisible=false,
        bottomspinevisible=false,
        xlabelfont=FONTS.family,
        xlabelsize=FONTS.axes_label_size,
        xticklabelfont=FONTS.family,
        ylabelfont=FONTS.family,
        ylabelsize=FONTS.axes_label_size,
        yticklabelfont=FONTS.family,
    )

    xlabel = AXIS[lang].cum_mean_benefit

    rainclouds!(
        ax,
        category_labels,
        category_data;
        xlabel=xlabel,
        clouds=nothing,
        plot_boxplots=false,
        markersize=15,
        jitter_width=0.3,
        side_nudge=0.05,
        color=category_colors,
        orientation=:horizontal,
    )

    _render_average_benefits_legend!(f, color_palette, countries, lang)

    return f
end

function _render_average_benefits_legend!(
    f::Figure, colors, countries::Vector{Symbol}, lang::Symbol
)::Nothing
    marker_elements = [
        MarkerElement(; color=colors[i], marker=:circle) for i in eachindex(countries)
    ]

    _labels = [LABELS[lang].countries[c] for c in countries]
    Legend(
        f[1, 2],
        marker_elements,
        _labels;
        markersize=ELEMENTS.legend_marker_size,
        labelsize=FONTS.legend_label_size,
        labelfont=FONTS.family,
        framevisible=false,
        rowgap=5,
    )
    return nothing
end
