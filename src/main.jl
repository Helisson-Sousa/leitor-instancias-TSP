include("tspreader.jl")
using LinearAlgebra
using JuMP
using GLPK
using Hungarian

mutable struct Node
    forbidden_arcs::Vector{Tuple{Int,Int}}   # lista de arcos proibidos no nó
    subtours::Vector{Vector{Int}}            # conjunto de subtours da solução
    lower_bound::Float64                     # custo total da solução do húngaro
    chosen::Int                              # índice do menor subtour
    feasible::Bool                           # indica se a solução é viável
end

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

    # identifica o menor subtour (por tamanho)
    subtour_lengths = [length(st) for st in subtours]
    chosen_idx = argmin(subtour_lengths)

    # cria o nó raiz da árvore
    node = Node(
        [],                         # sem arcos proibidos inicialmente
        subtours,                   # subtours encontrados
        cost,                       # custo do Hungarian
        chosen_idx,                 # índice do menor subtour
        length(subtours) == 1       # viável se for apenas um tour
    )

    println("\nNó criado:")
    println("  Custo (LB): ", node.lower_bound)
    println("  Subtour escolhido: ", node.subtours[node.chosen])
    println("  Viável: ", node.feasible)

    if node.feasible
        println("\nSolução é um tour único! Custo = $(node.lower_bound)")
    else
        println("\nExistem $(length(node.subtours)) subtours. Próximo passo: eliminar subtours (BnB).")
    end
end

main()