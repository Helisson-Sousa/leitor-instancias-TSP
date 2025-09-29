function branch_and_bound_dfs(data::Data; initial_upper=1e9, verbose=true)
    root = Node()
    updateNode!(root, data)

    tree = [root]              
    upper_bound = initial_upper
    best_node = nothing

    if verbose
        println("Root LB=$(root.lower_bound) feasible=$(root.feasible) #subtours=$(length(root.subtours))")
    end

    while !isempty(tree)
        println("============================================= tamanho da arvore= $(length(tree)) ")
        lb_values = [n.lower_bound for n in tree]           
        idx = argmin(lb_values)                            
        node = tree[idx]                                    
        deleteat!(tree, idx)           

        if node.lower_bound > upper_bound
            if verbose
                println("Pruned node LB=$(node.lower_bound) > UB=$(upper_bound)")
            end
            continue
        end

        if node.feasible
            if node.lower_bound < upper_bound
                upper_bound = node.lower_bound
                best_node = node
                if verbose
                    println("New incumbent UB=$(upper_bound)")
                end
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
                if verbose
                    println("Added child forbidding $(forbidden_arc) -> LB=$(n.lower_bound) feasible=$(n.feasible)")
                end
            else
                if verbose
                    println("Discarded child (LB=$(n.lower_bound) > UB=$(upper_bound)) forbidding $(forbidden_arc)")
                end
            end
        end
    end

    return best_node, upper_bound
end
