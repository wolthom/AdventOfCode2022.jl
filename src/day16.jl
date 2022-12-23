using LinearAlgebra

const valve_map_regex = r"Valve (\w*) [\w\s]*?=(\d*);[\w\s]*?valves? (.*)"

struct Valve
    name::Symbol
    rate::Int
    cons::Vector{Symbol} # Optimization idea: Use 64-bit bitmask to encode connections
end

function parse_match(m)
    name = Symbol(m[1])
    rate = parse(Int, m[2])
    cons = map(Symbol, eachsplit(m[3], ", "))
    Valve(name, rate, cons)
end

function parse_day16(inp_str)
    out = map(eachsplit(chomp(inp_str), '\n')) do line
        m = match(valve_map_regex, line)
        parse_match(m)
    end |> collect
    sort!(out; by=el->el.name)
end

function floyd_warshall(valves)
    # Set up connection matrix 
    valve_names = map(x->x.name, valves)
    num_valves = length(valve_names)
    sentinel = typemax(Int64) 
    dist_mat = fill(sentinel, num_valves, num_valves)
    @view(dist_mat[diagind(dist_mat)]) .= 0
    foreach(valves) do valve
        i = searchsortedfirst(valve_names, valve.name)
        for con in valve.cons
            j = searchsortedfirst(valve_names, con)
            dist_mat[i, j] = 1
        end
    end

    # Iteratively fill matrix 
    @inbounds for k in 1:num_valves
        for i in 1:num_valves
            for j in 1:num_valves
                a, b, c = (dist_mat[i, j], dist_mat[i, k], dist_mat[k, j])
                (b == sentinel || c == sentinel) && continue

                if a > (b + c)
                    dist_mat[i, j] = b + c
                end
            end
        end
    end
    dist_mat
end


struct CaveState
    time::Int64
    active::UInt64
    total_flow::Int64
    prev::Int64
end

function is_active(state, idx)
    (state.active & (1 << idx)) != 0x0
end

function calculate_pressures!(cache, state, search_idxs, dist_mat)
    # Update current state if it's an improvement
    cache[state.active] = max(get(cache, state.active, 0), state.total_flow)

    # Otherwise iterate over all search_idxs and recursively fill cache
    @inbounds for (idx, rate) in search_idxs
        new_time = state.time - dist_mat[state.prev, idx] - 1

        # Skip already active valves or candidates with too little time
        (is_active(state, idx) || new_time <= 0) && continue

        # Recurse into next state
        new_active = state.active | (1 << idx)
        new_flow = state.total_flow + new_time * rate
        new_state = CaveState(new_time, new_active, new_flow, idx)
        calculate_pressures!(cache, new_state, search_idxs, dist_mat)
    end

    return cache
end


function day16_part1(valves)
    # Calculate all pair-wise distances
    dist_mat = floyd_warshall(valves)

    # Store indices of relevant valves (i.e. flow rate > 0) to consider
    valve_names = map(x->x.name, valves)
    search_idxs = map(Iterators.filter(x -> x.rate > 0, valves)) do valve
        idx = searchsortedfirst(valve_names, valve.name)
        (idx, valve.rate)
    end 

    # Calculate the values of all possible states
    cache = Dict{Int64, Int64}()
    start_state = CaveState(30, 0x0, 0, 1)
    calculate_pressures!(cache, start_state, search_idxs, dist_mat)

    maximum(values(cache))
end

function day16_part2(valves)
end

