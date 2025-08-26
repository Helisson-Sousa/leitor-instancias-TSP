include("tspreader.jl")

function main()
    filename = joinpath(@__DIR__, "..", "instances", "a280.tsp")

    # cria objeto Data e lê a instância
    data = Data(2, filename)   # 2 parâmetros = nome do arquivo + instância
    read!(data)

    println("Instância: ", getInstanceName(data))
    println("Dimensão: ", data.dimension)
    println("Exemplo (1->2): ", data.distMatrix[1,2])

    println("\nExemplo de solução (1 -> 2 -> ... -> n -> 1):")
    cost = 0.0
    for i in 1:data.dimension-1
        print("$(i) -> ")
        cost += data.distMatrix[i, i+1]
    end
    cost += data.distMatrix[data.dimension, 1]
    println("$(data.dimension) -> 1")
    println("Custo de S: ", cost)
end

main()
