using DataFrames
using CSV

#* Internal 
include("../dict/setups.jl")
include("../dict/protocols.jl")
#include("../utilityFunction/smoothStepFunction.jl")

const OUTPUTDATAFOLDER = "results/outputData"

function foldersSetup(
	timestamp::Int64,
	country::String,
	utility::Int64,
)::Nothing
	pathTimestamp = "$(OUTPUTDATAFOLDER)/$(timestamp)"
	if !isdir(pathTimestamp)
		mkdir(pathTimestamp)
	end

	pathCountry = "$(pathTimestamp)/$(country)"
	if !isdir(pathCountry)
		mkdir(pathCountry)
	end

	utilFolderName = utilityFolderName(utility)
	pathUtilities = "$(pathCountry)/$(utilFolderName)"
	if !isdir(pathUtilities)
		mkdir(pathUtilities)
	end

	return nothing
end

function utilityFolderName(utility::Int64)::String
	return SETUPS[utility]["name"]
end

function rescaleBenefits(benefits::Vector{Float64})
	resultBenefits::Float64 = []

	for k in 1:length(benefits)
		factor::Float64 = 1.0

		if k > 1
			factor = reduce((x1, x2) -> x1 * (1 - x2), benefits[1:k-1]; init = 1)
		end

		push!(resultBenefits, benefits[k] * factor)
	end

	return resultBenefits
end

function writeBenefitCSV(
	benefitsA::Vector{Float64},
	benefitsB::Vector{Float64},
	protocolIndex::Int64,
	timestamp::Int64,
	country::String,
	utility::Int64,
)::Nothing

	# Change benefits scale to match the first iteration scale
	rescaledBenefitsA = rescaleBenefits(benefitsA)
	rescaledBenefitsB = rescaleBenefits(benefitsB)
	rescaledBenefits = DataFrame(A = rescaledBenefitsA, B = rescaledBenefitsB)

	# Export benefits to csv
	outDataPath = outputDataPath(timestamp, country, utility)
	protocolName = PROTOCOLS[protocolIndex]
	csvPath = "$(outDataPath)/benefit__$(protocolName).csv"
	CSV.write(csvPath, rescaledBenefits, header = true)

	return nothing
end

function outputDataPath(timestamp::Int64, country::String, utility::Int64)::String
	utilFolderName = utilityFolderName(utility)
	return ("$(OUTPUTDATAFOLDER)/$(timestamp)/$(country)/$(utilFolderName)")
end

function writeUtilityDensityCSV(
	utilityA,
	utilityB,
	timestamp,
	country,
	utility,
)::Nothing
	step = 0.001
	valuesA = [smoothStepFunction(x, utilityA.steps) for x in 0:step:1]
	valuesB = [smoothStepFunction(x, utilityB.steps) for x in 0:step:1]
	normalizedA = valuesA * utilityA.normalizationFactor
	normalizedB = valuesB * utilityB.normalizationFactor
	valuesMean = (normalizedA + normalizedB) / 2

	valuesDf = DataFrame(A = normalizedA, B = normalizedB, mean = valuesMean)

	# Export benefits to csv
	outDataPath = outputDataPath(timestamp, country, utility)
	csvPath = "$outDataPath/utility_density.csv"
	CSV.write(csvPath, valuesDf, header = true)

	return nothing
end
