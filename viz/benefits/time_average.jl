using AxisKeys
using CairoMakie
using Colors
using ColorSchemes
using NamedDims
using LaTeXStrings

function time_avg_ab_diff(
    benefits::NamedDimsArray;
    countries::Vector{Symbol}=[:usa],
    setup::Symbol=:default,
    label_letters::Bool=false,
    lang::Symbol=:en,
    cumulative::Bool=false,
)
    f = Figure()

    # 3-dimensional NamedDimsArray
    _benefits = if cumulative
        cumsum(benefits[:, :, :, Key(setup), :]; dims=1)
    else
        benefits[:, :, :, Key(setup), :]
    end

    strategies_keys = sort(Symbol.(get_axiskeys(_benefits, :strategies)))
    sort!(strategies_keys; by=x -> LABELS_LETTERS[:strategies][x])
    strategies_labels = label_letters ? LABELS_LETTERS.strategies : LABELS[lang].strategies

    #    y_low, y_high = get_y_limits(_benefits)
    #    n_cols, n_rows = get_cols_rows(n_figures)
    data_size = length(countries) * length(strategies_keys)
    category_data = zeros(data_size)
    category_labels = Array{String}(undef, data_size)

    # TODO: Sort out colors by country
    category_colors = Array{RGB}(undef, data_size)
    n_countries = length(countries)

    color_palette = ColorSchemes.tab20.colors[1:n_countries]

    for (idx_s, strategy) in enumerate(strategies_keys)
        for (idx_c, country) in enumerate(countries)
            index = idx_c + length(countries) * (idx_s - 1)

            A_benefit = _benefits[:, Key(:A), Key(strategy), Key(country)]
            B_benefit = _benefits[:, Key(:B), Key(strategy), Key(country)]
            category_data[index] = sum(abs.(A_benefit - B_benefit))
            category_labels[index] = strategies_labels[idx_s]
            category_colors[index] = color_palette[idx_c]
        end
    end

    ax = Axis(f[1, 1])

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

function time_avg_cum_mean(
    benefits::NamedDimsArray;
    countries::Vector{Symbol}=[:usa],
    setup::Symbol=:default,
    label_letters::Bool=false,
    lang::Symbol=:en,
)
    f = Figure()

    # 3-dimensional NamedDimsArray
    _benefits = benefits[:, :, :, Key(setup), :]

    strategies_keys = sort(Symbol.(get_axiskeys(_benefits, :strategies)))
    sort!(strategies_keys; by=x -> LABELS_LETTERS[:strategies][x])
    strategies_labels = label_letters ? LABELS_LETTERS.strategies : LABELS[lang].strategies

    #    y_low, y_high = get_y_limits(_benefits)
    #    n_cols, n_rows = get_cols_rows(n_figures)
    data_size = length(countries) * length(strategies_keys)
    category_data = zeros(data_size)
    category_labels = Array{String}(undef, data_size)

    category_colors = Array{RGB}(undef, data_size)
    n_countries = length(countries)

    color_palette = ColorSchemes.tab20.colors[1:n_countries]

    for (idx_s, strategy) in enumerate(strategies_keys)
        for (idx_c, country) in enumerate(countries)
            index = idx_c + length(countries) * (idx_s - 1)

            A_benefit = cumsum(_benefits[:, Key(:A), Key(strategy), Key(country)])
            B_benefit = cumsum(_benefits[:, Key(:B), Key(strategy), Key(country)])
            category_data[index] = sum((A_benefit + B_benefit) / 2) / size(_benefits, 1)
            category_labels[index] = strategies_labels[idx_s]
            category_colors[index] = color_palette[idx_c]
        end
    end

    ax = Axis(f[1, 1])

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
        MarkerElement(; color=colors[i], marker=:circle, markersize=10) for
        i in eachindex(countries)
    ]

    _labels = [LABELS[lang].countries[c] for c in countries]
    Legend(f[1, 2], marker_elements, _labels; framevisible=false, rowgap=5)
    return nothing
end
