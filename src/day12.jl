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

const deltas = CartesianIndex.((
    (-1, 0),
    (1, 0),
    (0, -1),
    (0, 1),
))

function count_steps(
    m::AbstractMatrix{<:Integer},
    steps::Matrix{<:Signed},
    start::Vector{CartesianIndex{2}},
    stop::CartesianIndex{2}
)
    # First initialize step-count of all fields to sentinel value 
    fill!(steps, eltype(steps)(-1))

    # Then initialize start positions to 0
    for i in start
        steps[i] = 0
    end

    # Allocate buffer to store next fields
    next = empty(start)
    @inbounds while !isempty(start)
        for index in start
            current_steps = steps[index]
            current_height = m[index]
            # Iterate over all possible neighbors
            for delta in deltas
                new_index = delta + index

                # Check if candidate should be skipped
                !checkbounds(Bool, m, new_index) && continue # Invalid index
                (steps[new_index] != -1) && continue # Already visited
                (m[new_index] - current_height) > 1 && continue # Unreachable

                # Stop iteration if target is found
                new_index == stop && return current_steps + 1

                # Initialize values of next step count
                steps[new_index] = current_steps + 1
                push!(next, new_index)
            end
        end
        # Empty start queue and alternate buffers
        empty!(start)
        (start, next) = (next, start)
    end
    steps
end

function day12_part1((sidx, eidx, field_map))
    steps = Matrix{Int16}(undef, size(field_map))
    count_steps(field_map, steps, [sidx], eidx)
end


function day12_part2((sidx, eidx, field_map))
    steps = Matrix{Int16}(undef, size(field_map))
    count_steps(field_map, steps, findall(==(0), field_map), eidx)
end
