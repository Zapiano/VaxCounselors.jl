using VaxCounselors

function summary(benefits::NamedDimsArray; lang=:en, fig_opts::Dict=Dict())::Figure
    resolution = get(fig_opts, :resolution, (750, 1400))
    f = Figure(; resolution=resolution)

    ab_diff = VaxCounselors.Metrics.avg_benefit_ab_diff(benefits)
    cum_ab_diff = VaxCounselors.Metrics.avg_benefit_ab_diff(benefits; cumulative=true)
    cum_mean_benefit = VaxCounselors.Metrics.avg_cum_mean_benefit(benefits)

    setups = axiskeys(benefits)[dim(benefits, :setups)]

    for (idx_s, setup) in enumerate(setups)
        g_nc = f[idx_s, 1] = GridLayout()  # Non-cumulative plot grid
        g_c = f[idx_s, 2] = GridLayout() # Cumulative plot grid

        abd = ab_diff[:, idx_s, :]
        cabd = cum_ab_diff[:, idx_s, :]
        cmb = cum_mean_benefit[:, idx_s, :]

        axis_opts_nc = Dict(
            :ylabel => AXIS[lang].abcumdiff,
            :xlabel => AXIS[lang].cum_mean_benefit,
            :label => LABELS[lang].setups[setup],
        )
        axis_opts_c = Dict(
            :ylabel => AXIS[lang].abdiff, :xlabel => AXIS[lang].cum_mean_benefit
        )
        VaxCounselors.Viz.jointplot(g_nc, cmb, cabd; axis_opts=axis_opts_nc)
        VaxCounselors.Viz.jointplot(g_c, cmb, abd; axis_opts=axis_opts_c)
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
    ax_main = Axis(g[2, 1]; xlabel=xlabel, ylabel=ylabel)
    ax_right = Axis(g[2, 2]; width=density_size)

    linkyaxes!(ax_main, ax_right)
    linkxaxes!(ax_main, ax_top)

    strategies = axiskeys(top_data)[dim(top_data, :strategies)]

    for strategy in strategies
        x_data = top_data[Key(strategy), :]
        y_data = right_data[Key(strategy), :]
        scatter!(ax_main, x_data, y_data; markersize=4, label=strategy)
        density!(ax_top, x_data)
        density!(ax_right, y_data; direction=:y)
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
