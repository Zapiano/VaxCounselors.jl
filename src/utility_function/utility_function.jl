module UtilityFunction

using QuadGK
using VaxCounselors: COUNTRIES, SETUPS, DEMOGRAPHICLABELS

include("./smooth_steps.jl")

export Utility,
	buildUtilities,
	updateUtility!,
	updateVaccinatedPopulation!,
	averageUtility,
	integrateUtility

mutable struct Utility
	steps::Vector{Dict}
	benefits::Vector{Float64}
	scaleFactor::Float64
	normalizationFactor::Float64
	# fraction of each age group vaccinated at each step
	vaccinatedPopulation::Array{Array{Float64}}
end

function labels(utility::Utility)::Array{AbstractString}
	return [step["label"] for step in utility.steps]
end

function buildUtilities(countryIndex::String, utilityIndex::Int64)
	stepsA::Vector{Dict} = buildUtilitySteps(countryIndex, utilityIndex, "A")
	stepsB::Vector{Dict} = buildUtilitySteps(countryIndex, utilityIndex, "B")

	utilityA = Utility(stepsA, [], 1, 1, [])
	utilityB = Utility(stepsB, [], 1, 1, [])

	updateNormalizationFactor!(utilityA)
	updateNormalizationFactor!(utilityB)

	return (utilityA, utilityB)
end

function buildUtilitySteps(countryIndex::String, utilityIndex::Int64, counselor::String)
	steps::Vector{Dict} = []

	intervals::Vector{Int64} = COUNTRIES[countryIndex]["demographic_intervals"]

	intervalStart::Rational{Int64} = 0 // 100
	intervalEnd::Rational{Int64} = 0 // 100
	for i in eachindex(intervals)
		intervalStart = intervalEnd
		intervalEnd = intervalStart + intervals[i] // 100
		range::Rational{Int64} = intervals[i] // 100

		step = Dict(
			"value" => SETUPS[utilityIndex]["values"][counselor][i],
			"label" => DEMOGRAPHICLABELS[i],
			"interval" => [intervalStart, intervalEnd],
			"range" => range::Rational{Int64},
		)

		push!(steps, step)
	end

	return steps
end

function updateNormalizationFactor!(utility::Utility)::Float64
	intervalStart::Float64 = 0.0
	intervalEnd::Float64 = 1.0

	# when using stepFunction:
	#value = integrateStepFunction(utility.steps, intervalStart, intervalEnd)

	# when using smoothFunction
	value::Float64 = integrateSmoothStepFunction(utility.steps, intervalStart, intervalEnd)
	#value::Float64, err = quadgk(normalizedFunction(utility), 0.0, 1.0, rtol=1e-8)

	utility.normalizationFactor = (1.0 / value)
end

function integrateUtility(utility::Utility, intervals::Vector{Vector{Float64}})::Float64
	result::Float64 = 0.0

	#integrateFunction = normalizedFunction(utility)
	for interval in intervals
		# when using stepFunction
		#value::Float64 = integrateStepFunction(utility.steps, intervalStart, intervalEnd)

		# when using smoothStepFunction
		value = integrateSmoothStepFunction(utility.steps, interval[1], interval[2])

		result += value
	end

	return result * utility.normalizationFactor
end

function averageUtility(stepsA::Vector{Dict},
	stepsB::Vector{Dict})
	normA::Float64 = sum([s["value"] * s["range"] for s in stepsA])
	normB::Float64 = sum([s["value"] * s["range"] for s in stepsB])

	averageSteps::Vector{Dict} = []

	for (stepA, stepB) in zip(stepsA, stepsB)
		averageValue = (stepA["value"] / normA + stepB["value"] / normB) / 2

		averageStep = Dict(
			"value" => averageValue,
			"label" => stepA["label"],
			"interval" => copy(stepA["interval"]),
			"range" => copy(stepA["range"]),
		)

		push!(averageSteps, averageStep)
	end

	avgUtility = Utility(averageSteps, [], 1, 1, [])

	updateNormalizationFactor!(avgUtility)

	return avgUtility
end

#*###################################
#########* Update Utility ###########
#*###################################

function updateUtility!(utility::Utility, vaccinatedIntervals::Vector{Vector{Float64}})
	# Compute benefits of vaccinated population and update utility
	updateBenefits!(utility, vaccinatedIntervals)

	# Remove vaccinated population from steps and update vaccinatedPopulation
	updateVaccinatedPopulation!(utility, vaccinatedIntervals)

	# Update scale factor
	updateScaleFactor!(utility, vaccinatedIntervals)

	# Remove empty steps and re-scale remaining ones
	removeEmptySteps!(utility)
	rescaleUtilitySteps!(utility, vaccinatedIntervals)

	# Integrate over whole utility to compute new normalization factor
	updateNormalizationFactor!(utility)
end

function updateBenefits!(
	utility::Utility,
	vaccinatedIntervals::Vector{Vector{Float64}},
)::Nothing
	push!(utility.benefits, integrateUtility(utility, vaccinatedIntervals))
	return nothing
end

function updateVaccinatedPopulation!(
	utility::Utility,
	vaccinatedIntervals::Vector{Vector{Float64}},
)::Nothing
	# Add new row to utility.vaccinatedPopulation to be updated later
	push!(utility.vaccinatedPopulation, zeros(length(DEMOGRAPHICLABELS)))

	for interval in vaccinatedIntervals
		for utilityStep in utility.steps
			vaccinatedInStep::Rational = vaccinatedPopulation(utilityStep, interval)
			utilityStep["range"] -= vaccinatedInStep

			# Find index of current step (discounting the skipped steps)
			label = utilityStep["label"]
			labelIndex = findfirst(isequal(label), DEMOGRAPHICLABELS)

			# update vaccinatedPopulation with current step
			rescaledPop = rescaledPopulation(utility, vaccinatedInStep)
			utility.vaccinatedPopulation[end][labelIndex] += rescaledPop
		end
	end

	return nothing
end

function vaccinatedPopulation(
	utilityStep::Dict,
	vaccinatedInterval::Vector{Float64},
)::Float64
	vaxIntervalStart, vaxIntervalEnd = vaccinatedInterval
	stepIntervalStart, stepIntervalEnd = utilityStep["interval"]

	vaxIntervalStartsIn = stepIntervalStart <= vaxIntervalStart < stepIntervalEnd
	vaxIntervalEndsIn = stepIntervalStart < vaxIntervalEnd <= stepIntervalEnd
	vaxIntervalStartsBefore = vaxIntervalStart < stepIntervalStart
	vaxIntervalEndsAfter = vaxIntervalEnd > stepIntervalEnd

	if (vaxIntervalStartsIn && vaxIntervalEndsIn)
		return (vaxIntervalEnd - vaxIntervalStart)
	elseif (vaxIntervalStartsIn && vaxIntervalEndsAfter)
		return (stepIntervalEnd - vaxIntervalStart)
	elseif (vaxIntervalStartsBefore && vaxIntervalEndsIn)
		return (vaxIntervalEnd - stepIntervalStart)
	elseif (vaxIntervalStartsBefore && vaxIntervalEndsAfter)
		return utilityStep["range"]
	else
		return 0.0
	end
end

function rescaledPopulation(utility::Utility, population::Rational)
	return population / (utility.scaleFactor)
end

function removeEmptySteps!(utility::Utility)::Nothing
	utility.steps = [step for step in utility.steps if step["range"] > 0.0001]
	return nothing
end

function scaleFactor(vaccinatedIntervals::Vector{Vector{Float64}})::Float64
	return (1 / (1 - sum([p2 - p1 for (p1, p2) in vaccinatedIntervals])))
end

function updateScaleFactor!(utility::Utility, vaccinatedIntervals::Vector)::Nothing
	utility.scaleFactor *= scaleFactor(vaccinatedIntervals)
	return nothing
end

function rescaleUtilitySteps!(
	utility::Utility,
	vaccinatedIntervals::Vector{Vector{Float64}},
)::Nothing
	scalefactor = scaleFactor(vaccinatedIntervals)

	startInterval = 0
	for utilityStep in utility.steps
		utilityStep["range"] *= scalefactor
		utilityStep["interval"][1] = startInterval
		utilityStep["interval"][2] = startInterval + utilityStep["range"]
		startInterval = utilityStep["interval"][2]
	end

	return nothing
end
end
