function logistic_function(x::AbstractFloat, d::AbstractFloat)::Float64
	B = 2000.0
	exp_arg = B * (d - x)
	result::Float64 = 1.0 / ((1.0 + exp(exp_arg)))

	return result
end

function smooth_step_function(x::AbstractFloat, utility_steps::Vector{Dict})::Float64
	result::Float64 = 0.0

	for i in eachindex(utility_steps)
		utility_step = utility_steps[i]
		step_value::Float64 = utility_step["value"]
		start_point::Float64 = utility_step["interval"][1]
		end_point::Float64 = utility_step["interval"][2]

		start_edge::Bool = (i == 1) #|| i == length(utilitySteps))
		end_edge::Bool = (i == length(utility_steps))
		#? I think instead of 1.0 it shoud be stepValue here...
		generalized_start::Float64 = start_edge ? 1.0 : logistic_function(x, start_point)
		generalized_end::Float64 = end_edge ? 0.0 : logistic_function(x, end_point)

		result += step_value * (generalized_start - generalized_end)
	end

	return result
end

function integrate_smooth_step_function(
	utility_steps::Vector{Dict},
	interval_start::Float64,
	interval_end::Float64,
)::Float64
	value, _ = quadgk(x -> smooth_step_function(x, utility_steps), interval_start, interval_end)

	return value
end
