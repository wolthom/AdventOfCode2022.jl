using DataStructures
using Missings

function find_positions(char_map)
    sidx, eidx = (CartesianIndex(0, 0), CartesianIndex(0, 0))

    for idx in CartesianIndices(char_map)
        if char_map[idx] == 'S'
            sidx = idx
        elseif char_map[idx] == 'E'
            eidx = idx
        end
    end

    (sidx, eidx)
end

function field_val(c)
    c ∈ 'a':'z' && return c - 'a'
    c == 'S' && return 'a' - 'a'
    c == 'E' && return 'z' - 'a'
end

function parse_day12(inp_str)
    # Create Char matrix
    char_map = permutedims(reduce(hcat, map(collect, eachsplit(inp_str, '\n'))))

    # Find start and end index
    sidx, eidx = find_positions(char_map)

    # Create Int matrix
    field_map = map(field_val, char_map)

    (sidx, eidx, field_map)
end

function reachable_neighbors(field_map, idx) 
    # Calculate neighbors as a NTuple{4, Union{Missing, CartesianIndex}}
    cur_height = field_map[idx]
    all_idxs = CartesianIndices(field_map)
    candidates = (
          CartesianIndex(idx[1]-1, idx[2]),
          CartesianIndex(idx[1]+1, idx[2]),
          CartesianIndex(idx[1], idx[2]-1),
          CartesianIndex(idx[1], idx[2]+1),
    )
    map(candidates) do c
        if !(c ∈ all_idxs) || field_map[c] - cur_height > 1
            missing
        else
            c
        end
    end
end

function min_dist(idx, target_idx, activate=true)
    if activate
        # Manhattan distance
        diff = target_idx - idx
        abs(diff[1]) + abs(diff[2])
    else
        0
    end
end

function a_star_search(sidx, eidx, field_map)
    # Set up search queue
    search_queue = PriorityQueue{CartesianIndex, Int}()
    enqueue!(search_queue, sidx => (0 + min_dist(sidx, eidx)))

    # History of visited fields
    visited = Set{CartesianIndex}()

    # A* search of path to end index
    while !isempty(search_queue)
        # Retrieve best candidate
        (idx, heuristic) = dequeue_pair!(search_queue)
        num_steps = heuristic - min_dist(idx, eidx)

        # Track visited fields
        push!(visited, idx)

        # Stop search if final location is reached
        idx == eidx && return num_steps

        # Otherwise add neighbors of current node to queue
        foreach(skipmissing(reachable_neighbors(field_map, idx))) do neighbor_idx
            # Ensure only valid and new fields are added to the queue
            if !haskey(search_queue, neighbor_idx) && !in(neighbor_idx, visited)
                enqueue!(search_queue, neighbor_idx => (num_steps + 1 + min_dist(neighbor_idx, eidx)))
            end
        end
    end
end

function day12_part1((sidx, eidx, field_map))
    a_star_search(sidx, eidx, field_map)
end

function day12_part2((_, eidx, field_map))
    candidates = findall(==(0), field_map)

    minimum(candidates) do idx
        res = a_star_search(idx, eidx, field_map)
        !isnothing(res) ? res : typemax(Int)
    end
end
