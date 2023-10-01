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
    ),
)

const LABELS_LETTERS = (
    strategies=(
        envy_free="(d)",
        maximize_benefit="(b)",
        minimize_benefit="(e)",
        oldest_first="(c)",
        random_vaccination="(a)",
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
)

const AXIS = (
    en=(utility="Utility", benefit="Benefit", timesteps="Time", population="Population"),
    pt=(
        utility="Utilidade", benefit="Benefício", timesteps="Tempo", population="População"
    ),
)
