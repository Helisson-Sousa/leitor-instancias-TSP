include("tspreader.jl")
using LinearAlgebra
using JuMP
using GLPK
using Hungarian

function main()
    filename = joinpath(@__DIR__, "..", "instances", "berlin52.tsp")

    # cria objeto Data e lê a instância
    data = Data(2, filename)
    read!(data)

    println("Instância: ", getInstanceName(data))
    println("Dimensão: ", data.dimension)

    assignment, cost = hungarian(data.distMatrix)

    println("Custo inicial do Hungarian: ", cost)    

    matrix = zeros(Int, data.dimension, data.dimension)
    for i in 1:data.dimension
        j = assignment[i]
        matrix[i, j] = 1
    end

    # lista de subtours
    subtours = Vector{Vector{Int64}}()

    # lista de vértices visitados
    visited = Vector{Int64}()

    # lista de vértices não visitados
    notVisited = collect(1:data.dimension)

    # enquanto houver vértices não visitados
    while !isempty(notVisited)
        tour = Int[]  # reinicia o tour atual
        i = notVisited[1]          # pega o primeiro vértice não visitado
        push!(tour, i)             # adiciona ao tour
        push!(visited, i)          # marca como visitado
        popfirst!(notVisited)      # remove de não visitados

        # percorre até voltar ao início
        while true
            j = assignment[i]      # vértice atribuído ao i
            push!(tour, j)         # adiciona no tour
            if !(j in visited)     # se ainda não foi visitado
                push!(visited, j)
                deleteat!(notVisited, findfirst(==(j), notVisited))
            end
            i = j
            if j == tour[1]        # se voltou ao início
                break
            end
        end

        push!(subtours, tour)      # guarda o subtour encontrado
    end

    # imprime subtours
    println("\nSubtours encontrados:")
    for (k, st) in enumerate(subtours)
        println("  Subtour $k: ", st)
    end

    if length(subtours) == 1
        println("\nSolução é um tour o único! Custo = $cost")
    else
        println("\nExistem $(length(subtours)) subtours. Próximo passo: eliminar subtours (BnB).")
    end
end

main()