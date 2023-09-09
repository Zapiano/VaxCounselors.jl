const SETUPS::Dict{Int64, Dict} = Dict(
	1 => Dict(
		"name" => "default",
		"values" => Dict("A" => [12, 16, 4, 1], "B" => [1, 4, 12, 16]),
	),
	2 => Dict(
		"name" => "symptomatology",
		"values" => Dict("A" => [12, 16, 4, 1], "B" => [1, 2, 7, 23]),
	),
	3 => (
		"name" => "transmissibility",
		"values" => Dict("A" => [7, 23, 2, 1], "B" => [1, 4, 12, 16]),
	),
	4 => Dict(
		"name" => "concentrated",
		"values" => Dict("A" => [7, 23, 2, 1], "B" => [1, 2, 7, 23]),
	),
	5 => Dict(
		"name" => "smaller",
		"values" => Dict("A" => [4, 5, 3, 2], "B" => [2, 3, 4, 5]),
	),
	6 => Dict(
		"name" => "mixed",
		"values" => Dict("A" => [4, 1, 16, 12], "B" => [16, 12, 1, 4]),
	),
)
