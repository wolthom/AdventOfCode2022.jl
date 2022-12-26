using OffsetArrays

@enum CubeType Unknown Air Rock

const NEIGHBOR_DELTAS = CartesianIndex.((
    (1, 0, 0),
    (-1, 0, 0),
    (0, 1, 0),
    (0, -1, 0),
    (0, 0, 1),
    (0, 0, -1),
))

const cube_line_regex = r"(\d*),(\d*),(\d*)"

function get_boundaries(cubes)
    min_coord = CartesianIndex(ntuple(x -> typemax(Int), Val(3)))
    max_coord = CartesianIndex(ntuple(x -> typemin(Int), Val(3)))
    for cube in cubes
        min_coord = min(min_coord, cube)
        max_coord = max(max_coord, cube)
    end
    i = oneunit(min_coord)
    (min_coord - i, max_coord + i)
end

function parse_day18(inp_str)
    cubes = CartesianIndex{3}[]
    foreach(eachsplit(chomp(inp_str), '\n')) do line
        x_str, y_str, z_str = match(cube_line_regex, line)
        x, y, z = (parse(Int, x_str), parse(Int, y_str), parse(Int, z_str))
        push!(cubes, CartesianIndex(x, y, z))
    end

    # Fill UInt8 matrix that denotes type of volume
    (min_coord, max_coord) = get_boundaries(cubes)
    volume = fill(Unknown, Tuple(max_coord - min_coord) .+ (1, 1, 1))
    volume = OffsetArray(volume, min_coord:max_coord)
    for cube in cubes
        volume[cube] = Rock
    end

    (cubes, volume)
end

function sides(cube, volume)
    6 - sum(NEIGHBOR_DELTAS) do delta
        idx = (cube + delta)
        volume[idx] == Rock
    end
end

function day18_part1((cubes, volume))
    exposed_sides = 0
    for cube in cubes
        exposed_sides += sides(cube, volume)
    end
    exposed_sides
end

function add_neighbors!(neighbors, cur_coord, volume)
    for delta in NEIGHBOR_DELTAS
        new_coord = cur_coord + delta

        # Skip invalid or already seen points
        checkbounds(Bool, volume, new_coord) || continue
        volume[new_coord] != Unknown && continue

        # Otherwise add point to list to be visited
        push!(neighbors, new_coord)
    end
end

function flood_fill!(volume)
    cur_coord = findfirst(==(Unknown), volume)

    neighbors = CartesianIndex{3}[]
    add_neighbors!(neighbors, cur_coord, volume)

    while length(neighbors) >= 1
        volume[cur_coord] = Air
        cur_coord = pop!(neighbors) 
        add_neighbors!(neighbors, cur_coord, volume)
    end
end

function sides_p2(cube, volume)
    sum(NEIGHBOR_DELTAS) do delta
        idx = (cube + delta)
        volume[idx] == Air
    end
end

function day18_part2((cubes, volume))
    volume = copy(volume)
    # Flood-fill air area
    flood_fill!(volume)

    # Calculate exposed sides based on air cubes
    exposed_sides = 0
    for cube in cubes
        exposed_sides += sides_p2(cube, volume)
    end

    exposed_sides
end
