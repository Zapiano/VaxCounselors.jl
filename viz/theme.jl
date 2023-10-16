using LaTeXStrings

const LABELS = (
    en=(
        strategies=(
            envy_free="Envy-Free",
            maximize_benefit="Maximize-Benefit",
            minimize_benefit="Minimize-Benefit",
            oldest_first="Oldest-First",
            random_vaccination="Random Vaccination",
        ),
        setups=(
            default="Default",
            transmissibility="Transmissibility",
            symptomatology="Symptomatology",
            concentrated="Concentrated",
        ),
        counselors=(A=L"C_A", B=L"C_B", mean="Mean"),
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
            envy_free="Envy-Free",
            maximize_benefit="Maximize-Benefit",
            minimize_benefit="Minimize-Benefit",
            oldest_first="Oldest-First",
            random_vaccination="Random Vaccination",
        ),
        setups=(
            default="Padrão",
            transmissibility="Transmissibilidade",
            symptomatology="Simtomatologia",
            concentrated="Concentrado",
        ),
        counselors=(A=L"C_A", B=L"C_B", mean="Média"),
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
        default="(a)", transmissibility="(b)", symptomatology="(c)", concentrated="(d)"
    ),
)

const COLORS = (
    counselors=(A="#FF4E00", B="#00B1FF", mean="#3a3a3a"),
    strategies=(
        envy_free=:red,
        maximize_benefit=:blue,
        minimize_benefit=:green,
        oldest_first=:brown,
        random_vaccination=:orange,
    ),
    age_groups=(ag0_14=:blue, ag15_24=:orange, ag25_64=:green, ag_65=:red),
)

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
