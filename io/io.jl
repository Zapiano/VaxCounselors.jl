using ..UtilityFunction

using DataFrames
using CSV

const OUTPUTDATAFOLDER = "results/data"

function folders_setup(timestamp::Int64, country::String, setup::Symbol)::Nothing
    pathTimestamp = "./$(OUTPUTDATAFOLDER)/$(timestamp)"
    if !isdir(pathTimestamp)
        mkdir(pathTimestamp)
    end

    pathCountry = "$(pathTimestamp)/$(country)"
    if !isdir(pathCountry)
        mkdir(pathCountry)
    end

    pathUtilities = "$(pathCountry)/$(setup)"
    if !isdir(pathUtilities)
        mkdir(pathUtilities)
    end

    return nothing
end

function write_utility_density_CSV(
    utility_A::UtilityFunction.Utility,
    utility_B::UtilityFunction.Utility,
    timestamp::Int64,
    country::String,
    setup::Symbol,
)::Nothing
    step = 0.001
    values_A = [UtilityFunction.smooth_step_function(x, utility_A.steps) for x in 0:step:1]
    values_B = [UtilityFunction.smooth_step_function(x, utility_B.steps) for x in 0:step:1]
    normalized_A = values_A * utility_A.normalization_factor
    normalized_B = values_B * utility_B.normalization_factor
    values_mean = (normalized_A + normalized_B) / 2

    values_df = DataFrame(; A=normalized_A, B=normalized_B, mean=values_mean)

    # Export benefits to csv
    out_data_path = _output_data_path(timestamp, country, setup)
    csv_path = "$(out_data_path)/utility_density.csv"
    CSV.write(csv_path, values_df; header=true)

    return nothing
end

function write_vaccinated_population_CSV(
    vaccinated_population, strategy::Symbol, timestamp, country, utility
)::Nothing
    timesteps = length(vaccinated_population)
    n_age_groups = length(vaccinated_population[1])

    _vax_pop = reshape(vcat(vaccinated_population...), n_age_groups, timesteps)'
    col_names = [:ag0_14, :ag15_24, :ag25_64, :ag_65]
    vax_pop = DataFrame(_vax_pop, col_names)

    out_path = _output_data_path(timestamp, country, utility)
    csv_path = "$(out_path)/vaccinated_population__$(strategy).csv"

    CSV.write(csv_path, vax_pop; header=true)

    return nothing
end

function write_benefits_CSV(
    benefitsA::Vector{Float64},
    benefitsB::Vector{Float64},
    strategy::Symbol,
    timestamp::Int64,
    country::String,
    setup::Symbol,
)::Nothing
    # Change benefits scale to match the first iteration scale
    rescaledBenefitsA = _rescale_benefits(benefitsA)
    rescaledBenefitsB = _rescale_benefits(benefitsB)
    rescaledBenefits = DataFrame(; A=rescaledBenefitsA, B=rescaledBenefitsB)

    # Export benefits to csv
    outDataPath = _output_data_path(timestamp, country, setup)
    csvPath = "$(outDataPath)/benefit__$(strategy).csv"
    CSV.write(csvPath, rescaledBenefits; header=true)

    return nothing
end

function _rescale_benefits(benefits::Vector{Float64})
    benefits_length = length(benefits)
    resultBenefits = zeros(Float64, benefits_length)

    for k in 1:benefits_length
        factor::Float64 = 1.0

        if k > 1
            factor = reduce((x1, x2) -> x1 * (1 - x2), benefits[1:(k - 1)]; init=1)
        end

        resultBenefits[k] = benefits[k] * factor
    end

    return resultBenefits
end

function _output_data_path(timestamp::Int64, country::String, setup::Symbol)::String
    return ("$(OUTPUTDATAFOLDER)/$(timestamp)/$(country)/$(setup)")
end
