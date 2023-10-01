using AxisKeys
using CairoMakie
using NamedDims
using LaTeXStrings

#function average_benefit_mean()
function average_benefit_ab_diff(
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
    category_colors = Array{String}(undef, data_size)

    for (idx_s, strategy) in enumerate(strategies_keys)
        for (idx_c, country) in enumerate(countries)
            index = idx_c + length(countries) * (idx_s - 1)

            A_benefit = _benefits[:, Key(:A), Key(strategy), Key(country)]
            B_benefit = _benefits[:, Key(:B), Key(strategy), Key(country)]
            category_data[index] = sum(abs.(A_benefit - B_benefit))
            category_labels[index] = strategies_labels[idx_s]
        end
    end

    ax = Axis(f[1, 1])
    colors = Makie.wong_colors()
    rainclouds!(
        ax,
        category_labels,
        category_data;
        xlabel="A-B Difference",
        clouds=nothing,
        plot_boxplots=false,
        markersize=15,
        jitter_width=0.3,
        side_nudge=0.05,
        color=colors[indexin(category_labels, unique(category_labels))],
        orientation=:horizontal,
    )

    #_render_benefits_legend!(f, lang)

    return f
end

#function _render_benefits_legend!(f, lang)::Nothing
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
