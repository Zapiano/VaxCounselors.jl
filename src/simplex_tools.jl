module SimplexTools

using Statistics

#* Internal
using VaxCounselors.UtilityFunction

export Simplex,
	EFPoint,
	buildSimplex,
	envyFreePoint

const SIDES = ["I", "II"]

mutable struct Point{F <: Float64, S <: String}
	p::F
	counselor::S
	choosedSide::S
	totalBenefit::F
end

struct Simplex
	divisions::Int64
	vaccinesFraction::Float64
	points::Vector{Point}
end

function Simplex(
	divisions::Int64,
	vaccines_fraction::Float64,
	utility_A::UtilityFunction.Utility,
	utility_B::UtilityFunction.Utility,
)::Simplex
	points::Vector{Point} = _simplex_points(divisions)

	# Label points and make counselors choose a side for each point
	_update_simplex_points!(points, vaccines_fraction, utility_A, utility_B)

	return Simplex(divisions, vaccines_fraction, points)
end

struct EFPoint{F <: Float64, S <: String}
	p::F
	vaccinationIntervals::Vector{Vector{F}}
	sideA::S
	sideB::S
	benefitA::F
	benefitB::F
end

function EFPoint(
	simplex::Simplex,
	utility_A::UtilityFunction.Utility,
	utility_B::UtilityFunction.Utility,
)::EFPoint
	ef_points::Vector{EFPoint} = _envy_free_points(simplex, utility_A, utility_B)

	return _best_envy_free_point(ef_points)
end

function _simplex_points(divisions::Int64)::Vector{Point}
	points::Vector{Point} = Vector{Point}(undef, divisions + 1)
	counselors = ["A", "B"]

	for (idx, d) in enumerate(0:divisions)
		points[idx] = Point(
			d / divisions,
			counselors[d%2+1],
			"",
			0.0)
	end

	return points
end

#*********************   Find Envy Free Points   ********************#

function _update_simplex_points!(
	points::Vector{Point},
	vaccines_fraction::Float64,
	utility_A::UtilityFunction.Utility,
	utility_B::UtilityFunction.Utility,
)::Nothing
	for point in points
		choosed_side, benefit = _choose_side(
			point,
			vaccines_fraction,
			utility_A,
			utility_B,
		)

		point.choosedSide = choosed_side
		point.totalBenefit = benefit
	end

	return nothing
end

function _choose_side(
	point::Point,
	vaccines_fraction::Float64,
	utility_A::UtilityFunction.Utility,
	utility_B::UtilityFunction.Utility,
)::Tuple{String, Float64}
	# Benefit and Maximum Region for current counselor choosing sides I or II
	benefit_I = _evaluate_side(point, vaccines_fraction, SIDES[1], utility_A, utility_B)
	benefit_II = _evaluate_side(point, vaccines_fraction, SIDES[2], utility_A, utility_B)

	# If choice_I and choice_II benefits are equal, return side I for counselor A and II for B
	# Otherwise return the greatest benefit
	if benefit_I == benefit_II
		return point.counselor == "A" ? (SIDES[1], benefit_I) : (SIDES[2], benefit_II)
	else
		return benefit_I > benefit_II ? (SIDES[1], benefit_I) : (SIDES[2], benefit_II)
	end
end

# Total utility for a given counselor (A or B)
# Choosing a specific side (I or II) at some point
function _evaluate_side(
	point::Point,
	vaccines_fraction::Float64,
	side::String,
	utility_A::UtilityFunction.Utility,
	utility_B::UtilityFunction.Utility,
)::Float64
	# Vectors with current and opposite utilities and sides, in that order
	utilities::Vector{UtilityFunction.Utility} = [utility_A, utility_B]
	point.counselor == "A" || reverse!(utilities)
	sides::Vector{String} = [side, filter(!=(side), SIDES)[1]]

	# Vector with current and opposite vaccination intervals, in that order
	intervals = _vax_intervals(point.p, utilities, sides, vaccines_fraction)

	# Benefits of choosing current and opposite sides
	# (at current and opposite counselors maximum regions)
	current_utilities = [utilities[1], utilities[1]]
	benefits = map(UtilityFunction.integrate_utility, current_utilities, [intervals])

	return sum(benefits)
end

function _vax_intervals(
	p::Float64,
	utilities::Vector{UtilityFunction.Utility},
	sides::Vector{String},
	vaccines_fraction::Float64,
)::Vector{Vector{Float64}}
	population_fractions = sides[1] == "I" ? [p, 1 - p] : [1 - p, p]
	vax_fractions = vaccines_fraction .* population_fractions
	utilities_steps = broadcast(x -> x.steps, utilities)

	# return a function that finds the maximum for specific point p
	function maximum_intervals(u_steps::Vector{Dict}, side::String, region_size::Float64)
		return UtilityFunction.mini_max_intervals(u_steps, p, side, region_size, "maximum")
	end

	max_intervals = map(maximum_intervals, utilities_steps, sides, vax_fractions)

	return vcat(max_intervals[1], max_intervals[2])
end

function _envy_free_points(
	simplex::Simplex,
	utilityA::UtilityFunction.Utility,
	utilityB::UtilityFunction.Utility,
)::Vector{EFPoint}

	ef_points::Vector{EFPoint} = []

	for i in 1:(length(simplex.points)-1)
		point_1::Point = simplex.points[i]
		point_2::Point = simplex.points[i+1]

		# Two consecutive points with different choosedSides form an Envy Free pair
		is_ef_pair = point_1.choosedSide != point_2.choosedSide
		if is_ef_pair
			# The mean point between an Envy Free Pair is a EFPoint
			push!(ef_points, _mean_point(simplex, point_1, point_2, utilityA, utilityB))
		end
	end

	return ef_points
end

function _mean_point(
	simplex::Simplex,
	point_1::Point,
	point_2::Point,
	utility_A::UtilityFunction.Utility,
	utility_B::UtilityFunction.Utility,
)::EFPoint
	# counselors A and B points, in that order
	points::Vector{Point} = sort([point_1, point_2], by = point -> point.counselor)
	p::Float64 = mean(broadcast(x -> x.p, points))

	# counselors A and B sides and utilities, in that order
	sides = map(point -> point.choosedSide, points)
	utilities = [utility_A, utility_B]

	# A and B counselors vaccination intervals
	intervals = _vax_intervals(p, utilities, sides, simplex.vaccinesFraction)

	# counselors A and B benefits, in that order
	benefits = broadcast(UtilityFunction.integrate_utility, utilities, [intervals, intervals])
	#Main.@infiltrate
	return EFPoint(p, intervals, sides[1], sides[2], benefits[1], benefits[2])
end

#*********************   Find Best Envy Free Point   ********************#

function _best_envy_free_point(points::Vector{EFPoint})::EFPoint
	balanced_points = _balanced_benefits_points(points)

	if length(balanced_points) == 1
		return balanced_points[1]
	end

	return _greatest_benefit_points(balanced_points)[1]
end

# return point(s) with the smallest difference between benefitA and benefitB
function _balanced_benefits_points(points::Vector{EFPoint})::Vector{EFPoint}
	balanced_points = Vector{Point}(undef, 0)

	smallest_difference = +Inf64

	for point in points
		difference = abs(point.benefitA - point.benefitB)

		if difference < smallest_difference
			balanced_points = [point]
			smallest_difference = difference
		elseif difference == smallest_difference
			push!(balanced_points, point)
		end
	end

	return balanced_points
end

function _greatest_benefit_points(points::Vector{EFPoint})::Vector{EFPoint}
	greatest_points::Vector{EFPoint} = []
	greatest_benefit = -Inf32

	for point in points
		total_benefit = point.benefitA + point.benefitB

		if total_benefit > greatest_benefit
			greatest_points = [point]
			greatest_benefit = total_benefit
		elseif total_benefit == greatest_benefit
			push!(greatest_points, point)
		end
	end

	return greatest_points
end
end
