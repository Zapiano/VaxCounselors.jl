module UtilityFunction

using QuadGK
using VaxCounselors: COUNTRIES, SETUPS, DEMOGRAPHICLABELS

include("./smooth_steps.jl")

export Utility,
	build_utilities,
	update_utility!,
	#_update_vaccinated_population!,
	average_utility,
	integrate_utility

mutable struct Utility
	steps::Vector{Dict}
	benefits::Vector{Float64}
	scale_factor::Float64
	normalization_factor::Float64
	vaccinated_population::Array{Array{Float64}} # frac of each age group vaccinated per step
end

function labels(utility::Utility)::Array{AbstractString}
	return [step["label"] for step in utility.steps]
end

function build_utilities(country_index::String, utility_index::Int64)
	steps_A::Vector{Dict} = _build_utility_steps(country_index, utility_index, "A")
	steps_B::Vector{Dict} = _build_utility_steps(country_index, utility_index, "B")

	utility_A = Utility(steps_A, [], 1, 1, [])
	utility_B = Utility(steps_B, [], 1, 1, [])

	_update_normalization_factor!(utility_A)
	_update_normalization_factor!(utility_B)

	return (utility_A, utility_B)
end

function _build_utility_steps(country_index::String, utility_ondex::Int64, counselor::String)
	steps::Vector{Dict} = []

	intervals::Vector{Int64} = COUNTRIES[country_index]["demographic_intervals"]

	interval_start::Rational{Int64} = 0 // 100
	interval_end::Rational{Int64} = 0 // 100
	for i in eachindex(intervals)
		interval_start = interval_end
		interval_end = interval_start + intervals[i] // 100
		range::Rational{Int64} = intervals[i] // 100

		step = Dict(
			"value" => SETUPS[utility_ondex]["values"][counselor][i],
			"label" => DEMOGRAPHICLABELS[i],
			"interval" => [interval_start, interval_end],
			"range" => range::Rational{Int64},
		)

		push!(steps, step)
	end

	return steps
end

function _update_normalization_factor!(utility::Utility)::Float64
	interval_start::Float64 = 0.0
	interval_end::Float64 = 1.0

	# when using stepFunction:
	#value = integrateStepFunction(utility.steps, intervalStart, intervalEnd)

	# when using smoothFunction
	value::Float64 = integrate_smooth_step_function(
		utility.steps,
		interval_start,
		interval_end,
	)
	#value::Float64, err = quadgk(normalizedFunction(utility), 0.0, 1.0, rtol=1e-8)

	utility.normalization_factor = (1.0 / value)
end

function integrate_utility(utility::Utility, intervals::Vector{Vector{Float64}})::Float64
	result::Float64 = 0.0

	#integrateFunction = normalizedFunction(utility)
	for interval in intervals
		# when using stepFunction
		#value::Float64 = integrateStepFunction(utility.steps, intervalStart, intervalEnd)

		# when using smoothStepFunction
		value = integrate_smooth_step_function(utility.steps, interval[1], interval[2])

		result += value
	end

	return result * utility.normalization_factor
end

function average_utility(steps_A::Vector{Dict}, steps_B::Vector{Dict})::Utility
	norm_A::Float64 = sum([s["value"] * s["range"] for s in steps_A])
	norm_B::Float64 = sum([s["value"] * s["range"] for s in steps_B])

	average_steps::Vector{Dict} = []

	for (step_A, step_B) in zip(steps_A, steps_B)
		average_value = (step_A["value"] / norm_A + step_B["value"] / norm_B) / 2

		average_step = Dict(
			"value" => average_value,
			"label" => step_A["label"],
			"interval" => copy(step_A["interval"]),
			"range" => copy(step_A["range"]),
		)

		push!(average_steps, average_step)
	end

	avg_utility = Utility(average_steps, [], 1, 1, [])

	_update_normalization_factor!(avg_utility)

	return avg_utility
end

#*###################################
#########* Update Utility ###########
#*###################################

function update_utility!(utility::Utility, vaccinated_intervals::Vector{Vector{Float64}})
	# Compute benefits of vaccinated population and update utility
	_update_benefits!(utility, vaccinated_intervals)

	# Remove vaccinated population from steps and update vaccinated_population
	_update_vaccinated_population!(utility, vaccinated_intervals)

	# Update scale factor
	_update_scale_factor!(utility, vaccinated_intervals)

	# Remove empty steps and re-scale remaining ones
	_remove_empty_steps!(utility)
	_rescale_utility_steps!(utility, vaccinated_intervals)

	# Integrate over whole utility to compute new normalization factor
	_update_normalization_factor!(utility)
end

function _update_benefits!(
	utility::Utility,
	vaccinated_intervals::Vector{Vector{Float64}},
)::Nothing
	push!(utility.benefits, integrate_utility(utility, vaccinated_intervals))
	return nothing
end

function _update_vaccinated_population!(
	utility::Utility,
	vaccinated_intervals::Vector{Vector{Float64}},
)::Nothing
	# Add new row to utility.vaccinated_population to be updated later
	push!(utility.vaccinated_population, zeros(length(DEMOGRAPHICLABELS)))

	for interval in vaccinated_intervals
		for utility_step in utility.steps
			vaccinated_in_step::Rational = _vaccinated_population(utility_step, interval)
			utility_step["range"] -= vaccinated_in_step

			# Find index of current step (discounting the skipped steps)
			label = utility_step["label"]
			label_index = findfirst(isequal(label), DEMOGRAPHICLABELS)

			# update vaccinated_population with current step
			rescaled_pop = _rescaled_population(utility, vaccinated_in_step)
			utility.vaccinated_population[end][label_index] += rescaled_pop
		end
	end

	return nothing
end

function _vaccinated_population(
	utility_step::Dict,
	vaccinated_interval::Vector{Float64},
)::Float64
	vax_interval_start, vax_interval_end = vaccinated_interval
	step_interval_start, step_interval_end = utility_step["interval"]

	vax_interval_starts_in = step_interval_start <= vax_interval_start < step_interval_end
	vax_interval_ends_in = step_interval_start < vax_interval_end <= step_interval_end
	vax_interval_starts_before = vax_interval_start < step_interval_start
	vax_interval_ends_after = vax_interval_end > step_interval_end

	if (vax_interval_starts_in && vax_interval_ends_in)
		return (vax_interval_end - vax_interval_start)
	elseif (vax_interval_starts_in && vax_interval_ends_after)
		return (step_interval_end - vax_interval_start)
	elseif (vax_interval_starts_before && vax_interval_ends_in)
		return (vax_interval_end - step_interval_start)
	elseif (vax_interval_starts_before && vax_interval_ends_after)
		return utility_step["range"]
	else
		return 0.0
	end
end

function _rescaled_population(utility::Utility, population::Rational)
	return population / (utility.scale_factor)
end

function _remove_empty_steps!(utility::Utility)::Nothing
	utility.steps = [step for step in utility.steps if step["range"] > 0.0001]
	return nothing
end

function _scale_factor(vaccinated_intervals::Vector{Vector{Float64}})::Float64
	return (1 / (1 - sum([p2 - p1 for (p1, p2) in vaccinated_intervals])))
end

function _update_scale_factor!(utility::Utility, vaccinated_intervals::Vector)::Nothing
	utility.scale_factor *= _scale_factor(vaccinated_intervals)
	return nothing
end

function _rescale_utility_steps!(
	utility::Utility,
	vaccinated_intervals::Vector{Vector{Float64}},
)::Nothing
	scale_factor = _scale_factor(vaccinated_intervals)

	start_interval = 0
	for utility_step in utility.steps
		utility_step["range"] *= scale_factor
		utility_step["interval"][1] = start_interval
		utility_step["interval"][2] = start_interval + utility_step["range"]
		start_interval = utility_step["interval"][2]
	end

	return nothing
end
end
