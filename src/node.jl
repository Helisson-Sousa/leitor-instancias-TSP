# node.jl
using Hungarian

if !isdefined(Main, :Node)
    mutable struct Node
        forbidden_arcs::Vector{Tuple{Int,Int}}   
        subtours::Vector{Vector{Int}}            
        lower_bound::Float64                    
        chosen::Int                              
        feasible::Bool                           
    end

    Node() = Node(Vector{Tuple{Int,Int}}(), Vector{Vector{Int}}(), 0.0, 0, false)
end

if !isdefined(Main, :BIG_COST)
    const BIG_COST = 10^9
end

function updateNode!(node::Node, data::Data)
    costMatrix = copy(data.distMatrix)
    for (i, j) in node.forbidden_arcs
        if 1 ≤ i ≤ size(costMatrix,1) && 1 ≤ j ≤ size(costMatrix,2)
            costMatrix[i, j] = BIG_COST
        end
    end

    assignment, cost = hungarian(costMatrix)
    node.lower_bound = Float64(cost)

    subtours = Vector{Vector{Int}}()
    notVisited = collect(1:data.dimension)

    while !isempty(notVisited)
        tour = Int[]
        i = notVisited[1]
        push!(tour, i)
        popfirst!(notVisited)

        while true
            j = assignment[i]
            push!(tour, j)
            
            idx = findfirst(==(j), notVisited)
            if idx !== nothing
                deleteat!(notVisited, idx)
            end
            i = j
            if j == tour[1]
                break
            end
        end

        push!(subtours, tour)
    end

    node.subtours = subtours

    subtour_lengths = [length(st) for st in subtours]
    node.chosen = argmin(subtour_lengths)
    node.feasible = (length(subtours) == 1)
end
