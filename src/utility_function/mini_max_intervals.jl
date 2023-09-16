using Base.Threads

mutable struct Interval{F <: Float64}
	function_value::F
	limits::Vector{F}
	delta::F
end

# return an array with limits of max (or min) intervals
function mini_max_intervals(
	utility_steps::Vector{Dict},
	p::Float64,
	side::String,
	region_size::Float64,
	extreme_type::String,
)::Vector{Vector{Float64}}
	#TODO raise error insted of printing error u_u
	if side == "I" && (p < region_size)
		return "Region too big"
	end
	if side == "II" && ((1 - p) < region_size)
		return "Region too big"
	end
	if region_size == 0
		return []
	end

	# Breaks function domain in Intervals of the same size and,
	# for each Interval, evaluate the function
	step = 0.1 * region_size
	intervals::Vector{Interval} = evaluate_function(utility_steps, step, p, side)
	if length(intervals) == 0
		return []
	end

	# Get extreme intervals whose sizes sum up to region_size
	extreme_intervals = find_extreme_intervals(intervals, region_size, extreme_type)

	# Get limits of the intervals
	intervals_limits = [i.limits for i in extreme_intervals]

	# Merge all intervals that are next to each other
	return merge_sibling_intervals(intervals_limits)
end

# Return Points Array within [0,1] interval
# with the function evaluated at each mean point
function evaluate_function(
	utility_steps::Vector{Dict},
	step::Float64,
	p::Float64,
	side::String,
)::Vector{Interval}
	# Selects the domain the will be considered based on a point p and a side
	# Side I corresponds to the left side of p and side II to the right side
	domain_limits = side == "I" ? [0.0, p] : [p, 1.0]
	domain = range(start = domain_limits[1], stop = domain_limits[2], step = step)
	domain_length = length(domain)

	# Intervals that will be returned at the end
	intervals::Vector{Interval} = Vector{Interval}(undef, domain_length - 1)

	# Iterate through the domain, evaluate the function and create Interval
	@threads for i in 1:(domain_length-1)
		start_point::Float64 = domain[i]
		end_point::Float64 = domain[i+1]
		#end_point::Float64 = i == (domain_length - 2) ? 1 : domain[i + 1]
		delta = end_point - start_point
		mean_point::Float64 = (delta) / 2 + start_point
		function_value = smooth_step_function(mean_point, utility_steps)

		intervals[i] = Interval(function_value, [start_point, end_point], delta)
	end

	return intervals
end

function find_extreme_intervals(
	intervals::Array{Interval},
	region_size::Float64,
	extreme_type::String,
)::Vector{Interval}
	reverse = extreme_type == "maximum" ? true : false
	sorted_intervals = sort(intervals, by = x -> x.function_value, rev = reverse)

	# stop iteration when sum_delta reaches max_delta
	sum_delta::Float64 = 0.0
	max_delta::Float64 = region_size

	# select intervals whose delta sum up to max_delta
	result_intervals::Vector{Interval} = []
	for interval in sorted_intervals
		if sum_delta >= max_delta
			break
		end

		# last iteration: when an increment makes sum_delta bigger than max_delta
		if sum_delta + interval.delta > max_delta
			# redefine current interval delta and end limit
			interval.delta = max_delta - sum_delta
			interval.limits[2] = interval.limits[1] + interval.delta
		end

		sum_delta += interval.delta
		push!(result_intervals, interval)
	end

	return result_intervals
end

# Merge intervals whose end points match
# ex: [0.1, 0.2] and [0.2, 0.3] will become [0.1, 0.3]
# Return Array{Array{Float16}} of the merged intervals
function merge_sibling_intervals(
	intervals::Vector{Vector{Float64}},
)::Vector{Vector{Float64}}
	sorted_intervals = sort(intervals, by = x -> x[1])

	# initialize result with the first interval
	result::Vector{Vector{Float64}} = [sorted_intervals[1]]

	# merge intervals whose end/start match
	for i in 2:(length(sorted_intervals))
		if sorted_intervals[i][1] == result[end][2]
			result[end][2] = sorted_intervals[i][2]
		else
			push!(result, sorted_intervals[i])
		end
	end

	return result
end
