function logisticFunction(x::AbstractFloat,
	d::AbstractFloat)
	B = 2000.0
	expArg = B * (d - x)
	result::Float64 = 1.0 / ((1.0 + exp(expArg)))

	return result
end

function smoothStepFunction(x::AbstractFloat,
	utilitySteps::Vector{Dict})
	result::Float64 = 0.0

	for i in eachindex(utilitySteps)
		utilityStep = utilitySteps[i]
		stepValue::Float64 = utilityStep["value"]
		startPoint::Float64 = utilityStep["interval"][1]
		endPoint::Float64 = utilityStep["interval"][2]

		startEdge::Bool = (i == 1) #|| i == length(utilitySteps))
		endEdge::Bool = (i == length(utilitySteps))
		#? I think instead of 1.0 it shoud be stepValue here...
		generalizedStart::Float64 = startEdge ? 1.0 : logisticFunction(x, startPoint)
		generalizedEnd::Float64 = endEdge ? 0.0 : logisticFunction(x, endPoint)

		result += stepValue * (generalizedStart - generalizedEnd)
	end

	return result
end

function integrateSmoothStepFunction(
	utilitySteps::Vector{Dict},
	intervalStart::Float64,
	intervalEnd::Float64,
)::Float64
	value, _ = quadgk(x -> smoothStepFunction(x, utilitySteps), intervalStart, intervalEnd)

	return value
end
