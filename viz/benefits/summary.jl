using VaxCounselors

function summary(benefits::NamedDimsArray; lang=:en, fig_opts::Dict=Dict())::Figure
    resolution = get(fig_opts, :resolution, (850, 1400))
    f = Figure(; resolution=resolution)

    ncum_ab_diff = VaxCounselors.Metrics.avg_benefit_ab_diff(benefits)
    cum_ab_diff = VaxCounselors.Metrics.avg_benefit_ab_diff(benefits; cumulative=true)
    cum_mean_benefit = VaxCounselors.Metrics.avg_cum_mean_benefit(benefits)

    delta_y = 0.1
    y_low_c = max(minimum(cum_ab_diff) - delta_y * minimum(cum_ab_diff), 0)
    y_high_c = maximum(cum_ab_diff) + delta_y * maximum(cum_ab_diff)
    y_low_nc = max(minimum(ncum_ab_diff) - delta_y * minimum(cum_ab_diff), 0)
    y_high_nc = maximum(ncum_ab_diff) + delta_y * maximum(ncum_ab_diff)

    delta_x = 0.1
    x_low = max(minimum(cum_mean_benefit) - delta_x * minimum(cum_mean_benefit), 0)
    x_high = maximum(cum_mean_benefit) + delta_x * maximum(cum_mean_benefit)

    setups = copy(axiskeys(benefits)[dim(benefits, :setups)])
    sort!(setups; by=x -> LABELS_LETTERS.setups[x])

    for (idx_s, setup) in enumerate(setups)
        g_nc = f[idx_s, 1] = GridLayout()  # Non-cumulative plot grid
        g_c = f[idx_s, 2] = GridLayout() # Cumulative plot grid

        ncabd = ncum_ab_diff[:, Key(setup), :]
        cabd = cum_ab_diff[:, Key(setup), :]
        cmb = cum_mean_benefit[:, Key(setup), :]

        axis_opts_c = Dict(
            :ylabel => AXIS[lang].abcumdiff,
            :ylow => y_low_c,
            :yhigh => y_high_c,
            :xlabel => AXIS[lang].cum_mean_benefit,
            :xlow => x_low,
            :xhigh => x_high,
        )
        axis_opts_nc = Dict(
            :ylabel => AXIS[lang].abdiff,
            :ylow => y_low_nc,
            :yhigh => y_high_nc,
            :label => LABELS[lang].setups[setup],
            :xlabel => AXIS[lang].cum_mean_benefit,
            :xlow => x_low,
            :xhigh => x_high,
        )

        VaxCounselors.Viz.jointplot(g_c, cmb, cabd; axis_opts=axis_opts_c)
        VaxCounselors.Viz.jointplot(g_nc, cmb, ncabd; axis_opts=axis_opts_nc)
    end

    strategies = axiskeys(benefits)[dim(benefits, :strategies)]
    _render_summary_legend!(f, strategies, lang)

    return f
end

function jointplot(
    g::Union{GridPosition,GridLayout},
    top_data::NamedDimsArray,
    right_data::NamedDimsArray;
    axis_opts::Dict=Dict(),
)::Nothing
    density_size = 40

    xlabel = get(axis_opts, :xlabel, "")
    ylabel = get(axis_opts, :ylabel, "")

    xlow = get(axis_opts, :xlow, minimum(top_data))
    xhigh = get(axis_opts, :xhigh, maximum(top_data))
    ylow = get(axis_opts, :ylow, minimum(right_data))
    yhigh = get(axis_opts, :yhigh, maximum(right_data))

    theme = get(axis_opts, :theme, :darkgrid)
    bg_color = THEME[theme].backgroundcolor
    grid_color = THEME[theme].gridcolor
    grid_width = THEME[theme].gridwidth

    ax_top = Axis(
        g[1, 1];
        height=density_size,
        backgroundcolor=bg_color,
        xgridcolor=grid_color,
        xgridwidth=grid_width,
        ygridvisible=false,
        rightspinevisible=false,
        leftspinevisible=false,
        topspinevisible=false,
        bottomspinevisible=false,
    )
    ax_main = Axis(
        g[2, 1];
        xlabel=xlabel,
        ylabel=ylabel,
        limits=(xlow, xhigh, ylow, yhigh),
        backgroundcolor=bg_color,
        xgridcolor=grid_color,
        xgridwidth=grid_width,
        ygridcolor=grid_color,
        ygridwidth=grid_width,
        rightspinevisible=false,
        leftspinevisible=false,
        topspinevisible=false,
        bottomspinevisible=false,
    )
    ax_right = Axis(
        g[2, 2];
        width=density_size,
        backgroundcolor=bg_color,
        ygridcolor=grid_color,
        ygridwidth=grid_width,
        xgridvisible=false,
        rightspinevisible=false,
        leftspinevisible=false,
        topspinevisible=false,
        bottomspinevisible=false,
    )

    linkyaxes!(ax_main, ax_right)
    linkxaxes!(ax_main, ax_top)

    strategies = axiskeys(top_data)[dim(top_data, :strategies)]

    for strategy in strategies
        x_data = top_data[Key(strategy), :]
        y_data = right_data[Key(strategy), :]
        color = COLORS.strategies[strategy]
        alpha = 0.4
        density_stroke_width = 1.5
        scatter!(
            ax_main,
            x_data,
            y_data;
            markersize=5,
            label=strategy,
            color=color,
            strokewidth=0.5,
            strokecolor=:white,
        )
        density!(
            ax_top,
            x_data;
            color=(color, alpha),
            strokecolor=color,
            strokearound=true,
            strokewidth=density_stroke_width,
        )
        density!(
            ax_right,
            y_data;
            direction=:y,
            color=(color, alpha),
            strokecolor=color,
            strokearound=true,
            strokewidth=density_stroke_width,
        )
    end

    ylims!(ax_top; low=0)
    xlims!(ax_right; low=0)

    hidedecorations!(ax_top; grid=false)
    hidedecorations!(ax_right; grid=false)

    colgap!(g, 10)
    rowgap!(g, 10)

    label = get(axis_opts, :label, "")

    if !isempty(label)
        Label(
            g[2, 1:2, Left()],
            label;
            valign=:center,
            rotation=π / 2,
            font=:bold,
            padding=(0, 85, 0, 0),
            fontsize=20,
        )
    end

    return nothing
end

function _render_summary_legend!(f, strategies, lang)::Nothing
    line_elements = [
        MarkerElement(; color=COLORS.strategies[s], marker=:circle, linestyle=nothing) for
        s in strategies
    ]
    _labels = [LABELS[lang].strategies[s] for s in strategies]

    Legend(
        f[end + 1, 1:end],
        line_elements,
        _labels;
        orientation=:horizontal,
        framevisible=false,
        halign=:right,
        padding=(0, 30, 0, 0),
    )
    return nothing
end
