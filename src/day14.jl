using OffsetArrays

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
            field_map[idx] = 1
        end
    end
    # Add line for ground floor
    @view(field_map[end, begin:end]) .= 1
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
    # Part 2:
    #   Widen min / max in the x-axis direction by 200
    #   Widen max in the y-axis direction by 2
    min_idx = CartesianIndex(1, min_idx[2])
    max_idx += CartesianIndex(2, 0)

    # Allocate only the required map
    field_map = fill!(Matrix{Int8}(undef, max_idx[1]-min_idx[1]+1, max_idx[2]-min_idx[2]+1), 0)
    # Reset indices to match actual coordinates
    field_map = OffsetArray(field_map, min_idx:max_idx)
    # Set indices to desired range
    fill_map!(field_map, coords, min_idx)
 
    field_map
end

const steps = CartesianIndex.((
    (1, 0),
    (1, -1),
    (1, 1),
))

function show_region(field_map, idx)
    start_idx = CartesianIndex(max(1, idx[1]-10), idx[2]-10)
    end_idx = CartesianIndex(min(size(field_map)[1], idx[1]+20), idx[2]+10)
    println("~~~~~~~~ Idx: $idx ~~~~~~~~~")
    display(@view(field_map[start_idx:end_idx]))
    println()
end

function circ_shift!(queue)
    @inbounds for idx in length(queue):-1:2
        queue[idx] = queue[idx-1]
    end
end

function simulate_sand!(field_map, outlet)
    # This approach utilizes two key optimizations:
    #   1. Every time the sand moves, another unit is spawned and stored in a queue
    #   2. If the head piece of sand move, all following units can just take the position of its predecessor (see circ_shift!)
    #   3. If the head piece settles, the following pieces are actually moved until the first one that does not settle
    units = 0

    sand_queue = CartesianIndex{2}[]
    while true
        push!(sand_queue, outlet)
        # Advance all sand units if the current head unit settled
        idx = 1
        @inbounds while idx <= length(sand_queue)
            cur_pos = sand_queue[idx]
            prev_pos = cur_pos
            for step in steps
                new_pos = cur_pos + step
                # Finish simulation if the first unit of sand falls outside of the region
                if !checkbounds(Bool, field_map, new_pos) 
                    @goto finish_label
                end
                # Skip already placed fields
                field_map[new_pos] != 0 && continue
                # Update current position
                cur_pos = new_pos
                break
            end

            # If the current sand unit moved, all following ones can just inherit the position
            if cur_pos != prev_pos
                # Optimization: If the current head unit moved, the others can just follow the predecessor
                circ_shift!(sand_queue)
                sand_queue[1] = cur_pos
                break
            end

            # Otherwise pop current hand and store location
            pos = popfirst!(sand_queue)
            pos == outlet && @goto finish_label
            field_map[pos] = 2
            units += 1
        end
    end

    # Break out of simulation and return units of sand
    @label finish_label
    units
end

function day14_part1(field_map)
    # Cut off floor
    field_map = OffsetArrays.Origin(field_map)(field_map[begin:end-2, begin:end])
    sand_outlet = CartesianIndex(0, 500)
    simulate_sand!(field_map, sand_outlet)
end

function day14_part2(field_map)
    # Duplicate input
    field_map = copy(field_map)
    sand_outlet = CartesianIndex(0, 500)
    simulate_sand!(field_map, sand_outlet) + 1
end
