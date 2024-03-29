const LABELS = (
    en=(
        strategies=(
            envy_free="Envy-free",
            maximize_benefit="Maximize-benefit",
            minimize_benefit="Minimize-benefit",
            oldest_first="Oldest-first",
            random_vaccination="Random Vaccination",
        ),
        setups=(
            default="Default",
            symptomatology="Symptomatology",
            transmissibility="Transmissibility",
            concentrated="Concentrated",
        ),
        counselors=(A=rich("C", subscript("A")), B=rich("C", subscript("B")), mean="Mean"),
        countries=(
            usa="United States",
            chn="China",
            bra="Brazil",
            can="Canada",
            fra="France",
            aus="Australia",
            deu="Germany",
            jpn="Japan",
            rus="Russia",
            irn="Iran",
            zaf="South Africa",
            mex="Mexico",
        ),
        age_groups=(
            ag0_14="0 - 14 y.o.",
            ag15_24="15 - 25 y.o.",
            ag25_64="25 - 64 y.o.",
            ag_65="+65 y.o.",
        ),
    ),
    pt=(
        strategies=(
            envy_free="Envy-free",
            maximize_benefit="Maximize-benefit",
            minimize_benefit="Minimize-benefit",
            oldest_first="Oldest-first",
            random_vaccination="Random Vaccination",
        ),
        setups=(
            default="(1) Padrão",
            symptomatology="(2) Sintomatologia",
            transmissibility="(3) Transmissibilidade",
            concentrated="(4) Concentrado",
        ),
        counselors=(A=rich("C", subscript("A")), B=rich("C", subscript("B")), mean="Média"),
        countries=(
            usa="Estados Unidos",
            chn="China",
            bra="Brasil",
            can="Canadá",
            fra="França",
            aus="Austrália",
            deu="Alemanha",
            jpn="Japão",
            rus="Rússia",
            irn="Irã",
            zaf="África do Sul",
            mex="México",
        ),
        age_groups=(
            ag0_14="0 - 14 anos",
            ag15_24="15 - 25 anos",
            ag25_64="25 - 64 anos",
            ag_65="+65 anos",
        ),
    ),
)

const LABELS_LETTERS = (
    strategies=(
        random_vaccination="(a)",
        maximize_benefit="(b)",
        oldest_first="(c)",
        envy_free="(d)",
        minimize_benefit="(e)",
    ),
    setups=(
        default="(1)", symptomatology="(2)", transmissibility="(3)", concentrated="(4)"
    ),
)

const COLORS = (
    counselors=(A="#FF4E00", B="#00B1FF", mean=:gray10),
    counselors_utilities=(A=:purple1, B=:green4, mean=:gray10),
    strategies=(
        envy_free=:red,
        maximize_benefit=:blue,
        minimize_benefit=:green,
        oldest_first=:brown,
        random_vaccination=:orange,
    ),
    age_groups=(ag0_14=:blue, ag15_24=:orange, ag25_64=:green, ag_65=:red),
)

const THEME = (darkgrid=(backgroundcolor="#eaeaf2", gridcolor="#fafafc", gridwidth=3),)

const AXIS = (
    en=(
        utility="Utility",
        benefit="Benefit",
        timesteps="Time",
        population="Population",
        population_frac="Population Fraction",
        abdiff="A-B Difference",
        abcumdiff="Cumulative A-B Difference",
        cum_mean_benefit="Cumulative Mean Benefit",
    ),
    pt=(
        utility="Utilidade",
        benefit="Benefício",
        timesteps="Tempo",
        population="População",
        population_frac="Fração da População",
        abdiff="Diferença A-B",
        abcumdiff="Diferença A-B Cumulativa",
        cum_mean_benefit="Benefício Cumulativo Médio",
    ),
)

const STRATEGY_KEYS = (
    time_average=[
        :random_vaccination, :maximize_benefit, :minimize_benefit, :oldest_first, :envy_free
    ],
)

const FONTS = (axes_label_size=18, legend_label_size=18, title_size=22, family="serif")

const ELEMENTS = (
    legend_line_width=3, legend_marker_size=15, line_width=2.5, marker_size=10
)
