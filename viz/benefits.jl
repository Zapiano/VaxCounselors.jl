using AxisKeys
using CairoMakie
using NamedDims
using LaTeXStrings

function plot_benefits(
    benefits::NamedDimsArray; country=:usa, setup=:default, label_letters=true
)
    f = Figure()

    # 3-dimensional NamedDimsArray
    _benefits = benefits[:, :, :, Key(setup), Key(country)]
    strategies_keys = sort(Symbol.(_get_axiskeys(_benefits, :strategies)))
    sort!(strategies_keys; by=x -> LABELS_LETTERS[:strategies][x])
    strategies_labels = label_letters ? LABELS_LETTERS.strategies : LABELS.strategies

    y_low, y_high = get_y_limits(_benefits)

    n_figures = length(strategies_keys)
    n_cols, n_rows = get_cols_rows(n_figures)

    for col in 1:n_cols, row in 1:n_rows
        index = col + n_cols * (row - 1)

        if index <= n_figures
            strategy = strategies_keys[index]
            subtitle = strategies_labels[strategy]
            ax = Axis(
                f[row, col];
                title=subtitle,
                xlabel="Timesteps",
                ylabel="Benefit",
                limits=(nothing, (y_low, y_high)),
            )

            timesteps = _get_axiskeys(_benefits, :timesteps)
            benefits_A = collect(_benefits[:, Key(:A), Key(strategy)])
            benefits_B = collect(_benefits[:, Key(:B), Key(strategy)])
            benefits_mean = (benefits_A + benefits_B) / 2

            lines!(ax, timesteps, benefits_A; color=COLORS.counselors.A)
            lines!(ax, timesteps, benefits_B; color=COLORS.counselors.B)
            lines!(ax, timesteps, benefits_mean; color=COLORS.counselors.mean)
        end
    end

    _render_benefits_legend!(f)

    return f
end

function _render_benefits_legend!(f)::Nothing
    line_elements = [
        LineElement(; color=COLORS.counselors[c], linestyle=nothing) for
        c in [:A, :B, :mean]
    ]
    Legend(
        f[1:end, 3], line_elements, [L"C_A", L"C_B", "Mean"]; framevisible=false, rowgap=5
    )
    return nothing
end
