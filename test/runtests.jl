using Test
using SafeTestsets
using Logging
using Plots
using ProgressBars

dirs = ["unit", "examples"]  # publication has a lot of prints, redefine println to do nothing ?

exclude = [
    "04b_cl_cd_post_processing.jl",  # Needs updating for using new limit cycle and integration API
    "05_steady_states.jl",  # Broken eight/circle plots
    "05b_equilibriums.jl",  # Broken eight/circle plots
    "06c_all_limit_cycles.jl",  # Needs updating for using new limit cycle and integration API
    "06d_counting_cycles.jl",  # Humoungous error, mayeb rewrite it one day ?
    "07_optimization_examples.jl",  # Slow AND broken, see ECC paper for parametric optimization
    "07b_no_constraint_optim.jl",  # Needs updating for using new limit cycle and integration API
    "07d_sparse_optim_variants.jl",  # Idea for sparse, but code is broken
]

only = [
    #"04b_cl_cd_post_processing.jl",
    #"05_steady_states.jl",
    #"05b_equilibriums.jl",
    #"06c_all_limit_cycles.jl",
    #"06d_counting_cycles.jl",
    #"07_optimization_examples.jl",
    #"07b_no_constraint_optim.jl",
    #"07d_sparse_optim_variants.jl",
]

function is_excluded(filename, pattern, exclude, only)
    # @show filename
    # @show only
    # @show isempty(only)
    # @show filename in only
    if !isempty(only)
        return !(filename in only)  # if only is not empty, exclude if not in only
    end
    filename in exclude && return true  # else, is filename in excluded list ?
    return isnothing(match(pattern, filename))  # Else exclude if no match
end

pattern = r"\d[a-z]?_.*\.jl"

@time with_logger(SimpleLogger(Warn)) do
    for dir in dirs
        dir_path = joinpath(@__DIR__, dir)
        println(@testset "$dir" begin
            for filename in ProgressBar(sort(readdir(dir_path)))
                is_excluded(filename, pattern, exclude, only) && continue
                println(filename)
                filepath = joinpath(dir_path, filename)
                eval(quote
                    @safetestset $filename begin
                        include($filepath)
                    end
                end)
            end
        end)
    end
end
# @eval Plots gr_display(plt::Plots.Plot, dpi_factor=1) = tmp_gr_display
nothing
