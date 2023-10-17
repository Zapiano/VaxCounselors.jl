function utility_densities(
    utilities::NamedDimsArray; country=:usa, label_letters=false, lang=:en
)
    f = Figure()

    # 3-dimensional NamedDimsArray
    _utilities = utilities[:, :, :, Key(country)]
    setup_keys = sort(Symbol.(get_axiskeys(_utilities, :setups)))
    sort!(setup_keys; by=x -> LABELS_LETTERS[:setups][x])
    setup_labels = label_letters ? LABELS_LETTERS.setups : LABELS[lang].setups

    y_low, y_high = get_y_limits(_utilities)

    n_figures = length(setup_keys)
    n_cols, n_rows = get_cols_rows(n_figures)

    for col in 1:n_cols, row in 1:n_rows
        index = col + n_cols * (row - 1)

        if index <= n_figures
            setup = setup_keys[index]
            subtitle = setup_labels[setup]
            ax = Axis(
                f[row, col];
                title=subtitle,
                xlabel=AXIS[lang].population,
                ylabel=AXIS[lang].utility,
                limits=(nothing, (y_low, y_high)),
            )

            timesteps = get_axiskeys(_utilities, :timesteps)
            benefits_A = collect(_utilities[:, Key(:A), Key(setup)])
            benefits_B = collect(_utilities[:, Key(:B), Key(setup)])
            benefits_mean = collect(_utilities[:, Key(:mean), Key(setup)])

            lines!(ax, timesteps, benefits_A; color=COLORS.counselors.A)
            lines!(ax, timesteps, benefits_B; color=COLORS.counselors.B)
            lines!(ax, timesteps, benefits_mean; color=COLORS.counselors.mean)
        end
    end

    _render_utilities_legend!(f, lang)

    return f
end

function _render_utilities_legend!(f, lang)::Nothing
    line_elements = [
        LineElement(; color=COLORS.counselors[c], linestyle=nothing) for
        c in [:A, :B, :mean]
    ]
    _labels = LABELS[lang].counselors
    Legend(
        f[1:end, 3],
        line_elements,
        [_labels.A, _labels.B, _labels.mean];
        framevisible=false,
        rowgap=5,
    )
    return nothing
end
