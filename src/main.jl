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

    assignment, cost = hungarian(data.distMatrix)

    # Mostrar a matriz
    # println("Matriz de matching:")
    # println(assignment)
    # println("Custo", cost)

    matrix = zeros(data.dimension, data.dimension)
    # print(matrix)

    for i in 1:data.dimension
        j = assignment[i]
        matrix[i, j] = 1
    end
    # print(matrix)

    #criar vetor interno de tour
    tour = Vector{Int64}(undef, 0)

    # lista de vetores visitados

    visited = Vector{Int64}(undef, 0)

    #lista de vetores não visitados

    notVisited = Vector{Int64}(undef, 0)

    #Preenche vertices não visitados

    for i in 1:data.dimension
        push!(notVisited, i)
    end

    # print("visited", visited)
    # print("notVisited", notVisited)

    n = length(notVisited)

    # while n > 0
        i = notVisited[begin]
        popfirst!(notVisited)
        push!(visited, i)

        print("visited", visited)
        print("notVisited", notVisited)
    # end

    # pegue o primeiro vertice da lista de vertices não visitados
    # retire dos não visitados
    # adicione um vertice no tour
    
    # para os demais vertices :
    #   se tiver atribuido: 
    #     adicione  j nos vertices visitados
    #     remova j dos não visitados
    #     adicione no tour
    #     fazer i = j

    #   se a posição atual for igual o vertice inicial do tour
    #     adicione o tour no subtours
    #     limpe o tour

end

main()
