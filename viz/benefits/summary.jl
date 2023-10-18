using VaxCounselors

function summary(benefits::NamedDimsArray; lang=:en, fig_opts::Dict=Dict())::Figure
    resolution = get(fig_opts, :resolution, (750, 1400))
    f = Figure(; resolution=resolution)

    ncum_ab_diff = VaxCounselors.Metrics.avg_benefit_ab_diff(benefits)
    cum_ab_diff = VaxCounselors.Metrics.avg_benefit_ab_diff(benefits; cumulative=true)
    cum_mean_benefit = VaxCounselors.Metrics.avg_cum_mean_benefit(benefits)

    delta_y = 0.1
    y_low_c = minimum(cum_ab_diff) * (1 - delta_y)
    y_high_c = maximum(cum_ab_diff) * (1 + delta_y)
    y_low_nc = minimum(ncum_ab_diff) * (1 - delta_y)
    y_high_nc = maximum(ncum_ab_diff) * (1 + delta_y)

    delta_x = 0.1
    x_low = minimum(cum_mean_benefit) * (1 - delta_x)
    x_high = maximum(cum_mean_benefit) * (1 + delta_x)

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

    f

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

    ax_top = Axis(g[1, 1]; height=density_size)
    xlow = get(axis_opts, :xlow, minimum(top_data))
    xhigh = get(axis_opts, :xhigh, maximum(top_data))
    ylow = get(axis_opts, :ylow, minimum(right_data))
    yhigh = get(axis_opts, :yhigh, maximum(right_data))
    ax_main = Axis(
        g[2, 1]; xlabel=xlabel, ylabel=ylabel, limits=((xlow, xhigh), (ylow, yhigh))
    )
    ax_right = Axis(g[2, 2]; width=density_size)

    linkyaxes!(ax_main, ax_right)
    linkxaxes!(ax_main, ax_top)

    strategies = axiskeys(top_data)[dim(top_data, :strategies)]

    for strategy in strategies
        x_data = top_data[Key(strategy), :]
        y_data = right_data[Key(strategy), :]
        scatter!(
            ax_main,
            x_data,
            y_data;
            markersize=4,
            label=strategy,
            color=COLORS.strategies[strategy],
        )
        density!(ax_top, x_data; color=COLORS.strategies[strategy])
        density!(ax_right, y_data; direction=:y, color=COLORS.strategies[strategy])
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
            padding=(0, 70, 0, 0),
        )
    end

    return nothing
end
