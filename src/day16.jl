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


function day16_part1(valves)
    dist_mat = floyd_warshall(valves)
end

function day16_part2(inp)
end

