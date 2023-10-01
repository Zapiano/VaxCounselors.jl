const LABELS = (
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
