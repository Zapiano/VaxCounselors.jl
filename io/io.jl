using DataFrames
using CSV

const OUTPUTDATAFOLDER = "results/data"

function folders_setup(
	timestamp::Int64,
	country::String,
	utility::Int64,
)::Nothing
	pathTimestamp = "./$(OUTPUTDATAFOLDER)/$(timestamp)"
	if !isdir(pathTimestamp)
		mkdir(pathTimestamp)
	end

	pathCountry = "$(pathTimestamp)/$(country)"
	if !isdir(pathCountry)
		mkdir(pathCountry)
	end

	utilFolderName = _utility_folder_name(utility)
	pathUtilities = "$(pathCountry)/$(utilFolderName)"
	if !isdir(pathUtilities)
		mkdir(pathUtilities)
	end

	return nothing
end

function write_benefits_CSV(
	benefitsA::Vector{Float64},
	benefitsB::Vector{Float64},
	protocolIndex::Int64,
	timestamp::Int64,
	country::String,
	utility::Int64,
)::Nothing
	# Change benefits scale to match the first iteration scale

	rescaledBenefitsA = _rescale_benefits(benefitsA)
	rescaledBenefitsB = _rescale_benefits(benefitsB)
	rescaledBenefits = DataFrame(A = rescaledBenefitsA, B = rescaledBenefitsB)

	# Export benefits to csv
	outDataPath = _output_data_path(timestamp, country, utility)
	protocolName = PROTOCOLS[protocolIndex]
	csvPath = "$(outDataPath)/benefit__$(protocolName).csv"
	CSV.write(csvPath, rescaledBenefits, header = true)

	return nothing
end

function _utility_folder_name(utility::Int64)::String
	return SETUPS[utility]["name"]
end

function _rescale_benefits(benefits::Vector{Float64})
	benefits_length = length(benefits)
	resultBenefits = zeros(Float64, benefits_length)

	for k in 1:benefits_length
		factor::Float64 = 1.0

		if k > 1
			factor = reduce((x1, x2) -> x1 * (1 - x2), benefits[1:k-1]; init = 1)
		end

		resultBenefits[k] = benefits[k] * factor
	end

	return resultBenefits
end

function _output_data_path(timestamp::Int64, country::String, utility::Int64)::String
	utilFolderName = _utility_folder_name(utility)
	return ("$(OUTPUTDATAFOLDER)/$(timestamp)/$(country)/$(utilFolderName)")
end

#function write_utility_density_CSV(
#	utilityA,
#	utilityB,
#	timestamp,
#	country,
#	utility,
#)::Nothing
#	step = 0.001
#	valuesA = [smoothStepFunction(x, utilityA.steps) for x in 0:step:1]
#	valuesB = [smoothStepFunction(x, utilityB.steps) for x in 0:step:1]
#	normalizedA = valuesA * utilityA.normalizationFactor
#	normalizedB = valuesB * utilityB.normalizationFactor
#	valuesMean = (normalizedA + normalizedB) / 2
#
#	valuesDf = DataFrame(A = normalizedA, B = normalizedB, mean = valuesMean)
#
#	# Export benefits to csv
#	outDataPath = _output_data_path(timestamp, country, utility)
#	csvPath = "$outDataPath/utility_density.csv"
#	CSV.write(csvPath, valuesDf, header = true)
#
#	return nothing
#end
