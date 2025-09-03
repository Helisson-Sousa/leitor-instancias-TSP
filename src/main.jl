include("tspreader.jl")
using LinearAlgebra
using JuMP
using GLPK
using Hungarian

function main()
    filename = joinpath(@__DIR__, "..", "instances", "berlin52.tsp")

    # cria objeto Data e lê a instância
    data = Data(2, filename)   # 2 parâmetros = nome do arquivo + instância
    read!(data)

    println("Instância: ", getInstanceName(data))
    println("Dimensão: ", data.dimension)

    # for i in 1:data.dimension-1
    #     for j in 1:data.dimension-1
    #         println(data.distMatrix[i, j])
    #     end
    # end

    assignment, cost = hungarian(data.distMatrix)

    # Mostrar a matriz
    println("Matriz de matching:")
    println(assignment)
    println("Custo", cost)

    matrix = zeros(data.dimension, data.dimension)
    # print(matrix)

    for i in 1:data.dimension
        j = assignment[i]
        matrix[i, j] = 1
    end
    print(matrix)

end

main()
