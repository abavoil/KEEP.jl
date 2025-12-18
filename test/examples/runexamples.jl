using Test
using SafeTestsets
using Logging
using Plots
using ProgressBars
#=
exclude = [
    "03.5_ModelBenchmark.jl",  # Pas de tests
    "05.4.5_Equilibriums.jl",  # autodiff bug ???
    "05.6_AllLimitCyclesFromEquilibriums.jl",  # A réécrire avec les nouveaux cycles limites
    "05.7_CountingEquilibriumsAndLimitCycles.jl",  # WIP
    # "05.8_PhaseSpaceVisualization.jl",  # WIP
    "07.1_NoConstraintLimitCycleOptim.jl",  # Lent
    "07.2_LimitCycleOptimSparse.jl",  # WIP
    "07.2.5_OptimSparse.jl",  # WIP (duplicate of above)
    "07.3_OptimTests.jl",  # WIP, long runtime
]
=#
exclude = [
    "06c_all_limit_cycles.jl",  # Needs updating for using new limit cycle and integration API
    "06d_counting_cycles.jl",  # Humoungous error, mayeb rewrite it one day ?
    "07_optimization_examples.jl",  # Slow AND broken, see ECC paper for parametric optimization
    "07b_no_constraint_optim.jl",  # Needs updating for using new limit cycle and integration API
    "07d_optim_sparse.jl",  # Idea for sparse, but code is broken
]
# Numbering + underscore + capital + anything not underscore + .jl
pattern = r"\d\d[a-z]?_.*\.jl"

let tmp_gr_display = Plots.gr_display
    # Certains plots bugs pour l'instant, voir l'autre proposition de https://github.com/JuliaPlots/Plots.jl/issues/5061#issuecomment-2751010479
    # @eval Plots gr_display(plt::Plots.Plot, dpi_factor=1) = nothing
    @time with_logger(SimpleLogger(Warn)) do
        errors = []
        @testset "keep" begin
            for file in ProgressBar(sort(readdir(@__DIR__)))
                isnothing(match(pattern, file)) && continue
                file in exclude && continue
                # file < "06d" && continue
                println(file)
                eval(quote
                    @safetestset $file begin
                        include($file)
                    end
                end)
            end
        end
    end
    # @eval Plots gr_display(plt::Plots.Plot, dpi_factor=1) = tmp_gr_display
end
nothing
