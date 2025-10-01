function branch_and_bound_dfs(data::Data; initial_upper=1e9, verbose=true)

    print(data)

    root = Node()
    updateNode!(root, data)

    tree = [root]              
    upper_bound = initial_upper
    best_node = nothing
    gap = Inf

    while !isempty(tree) && gap > 0.001
        lb_values = [n.lower_bound for n in tree]
        dual = maximum(lb_values) 
        primal = upper_bound 
        gap = max((primal - dual) / primal * 100, 0.0)

        if verbose
            println("Tree size=$(length(tree)) | Primal=$(primal) | Dual=$(dual) | Gap=$(round(gap, digits=2))%")
        end

        idx = argmin(lb_values)                            
        node = tree[idx]                                    
        deleteat!(tree, idx)           

        if node.lower_bound > upper_bound
            continue
        end

        if node.feasible
            if node.lower_bound < upper_bound
                upper_bound = node.lower_bound
                best_node = node
            end
            continue
        end

        chosen_subtour = node.subtours[node.chosen]
        for i in 1:(length(chosen_subtour)-1)
            n = Node(copy(node.forbidden_arcs), [], 0.0, 0, false)
            forbidden_arc = (chosen_subtour[i], chosen_subtour[i+1])
            push!(n.forbidden_arcs, forbidden_arc)
            updateNode!(n, data)

            if n.lower_bound <= upper_bound
                push!(tree, n)
            end
        end
    end

    return best_node, upper_bound
end
