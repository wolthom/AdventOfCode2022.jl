const FieldEl = Union{Nothing, CartesianIndex{2}}

function calculate_fieldsize(coords)
    min_idx, max_idx = (coords[1], coords[1])

    @inbounds for idx in 1:length(coords)-1
        next_el = coords[idx+1]
        isnothing(next_el) && continue

        min_idx = min(min_idx, next_el)
        max_idx = max(max_idx, next_el)
    end
    (min_idx, max_idx)
end

function fill_map!(field_map, coords, min_idx)
    @inbounds for idx in 1:length(coords)-1
        cur_el, next_el = (coords[idx], coords[idx+1])

        # Skip segment gaps
        (isnothing(cur_el) || isnothing(next_el)) && continue
        
        # Mark each index as filled
        foreach(min(cur_el, next_el):max(cur_el, next_el)) do idx
            field_map[idx[1], idx[2] - min_idx[2] + 1] = 1
        end
    end
end

function parse_day14(inp_str)

    str_lines = eachsplit(inp_str, '\n')
    coords = FieldEl[]

    for line in str_lines
        for coord_str in eachsplit(line, " -> ")
            col_idx, row_idx = parse.(Int, split(coord_str, ','; limit=2))
            push!(coords, CartesianIndex(row_idx, col_idx))
        end
        push!(coords, nothing)
    end

    (min_idx, max_idx) = calculate_fieldsize(coords)
    num_rows, num_cols = (max_idx[1], max_idx[2] - min_idx[2] + 1)

    field_map = fill!(Matrix{Int8}(undef, num_rows, num_cols), 0)
    fill_map!(field_map, coords, min_idx)
 
    (field_map, min_idx)
end

const steps = CartesianIndex.((
    (1, 0),
    (1, -1),
    (1, 1),
))

function day14_part1((field_map, min_idx))
    sand_outlet = CartesianIndex(0, 500 - min_idx[2] + 1)
    units = 0

    pos = sand_outlet
    while true
        prev = pos

        # Try to advance unit of sand
        for step in steps
            new_pos = pos + step
            # Finish simulation if the first unit of sand falls outside of the region
            !checkbounds(Bool, field_map, new_pos) && @goto finish_label
            # Skip already placed fields
            field_map[new_pos] != 0 && continue
            # Take new position
            pos = new_pos
            break
        end
    
        # Try advancing again if successful
        prev != pos && continue

        # Otherwise store sand location and spawn next unit of sand
        field_map[pos] = 2
        units += 1
        pos = sand_outlet
    end

    # Break out of simulation and return units of sand
    @label finish_label
    units
end

function day14_part2(inp)
end
