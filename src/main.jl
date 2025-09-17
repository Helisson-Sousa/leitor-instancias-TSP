# main.jl
include("tspreader.jl")
include("node.jl")  
include("bnb.jl")    

function main()
    filename = joinpath(@__DIR__, "..", "instances", "bays29Ajustada.tsp")
    data = Data(2, filename)
    read!(data)

    println("Instância: ", getInstanceName(data))
    println("Dimensão: ", data.dimension)

    best_node, ub = branch_and_bound_dfs(data; initial_upper=1e9, verbose=true)

    if best_node === nothing
        println("\nNenhuma solução encontrada (UB = $ub)")
    else
        println("\nSolução encontrada UB = $ub")
    end
end


main()
