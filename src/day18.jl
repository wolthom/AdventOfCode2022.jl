const Point3D = Tuple{Int, Int, Int}

const NEIGHBOR_DELTAS = CartesianIndex.((
    (1, 0, 0),
    (-1, 0, 0),
    (0, 1, 0),
    (0, -1, 0),
    (0, 0, 1),
    (0, 0, -1),
))

const cube_line_regex = r"(\d*),(\d*),(\d*)"

function parse_day18(inp_str)
    cubes = Set{CartesianIndex{3}}()
    foreach(eachsplit(chomp(inp_str), '\n')) do line
        x_str, y_str, z_str = match(cube_line_regex, line)
        x, y, z = (parse(Int, x_str), parse(Int, y_str), parse(Int, z_str))
        push!(cubes, CartesianIndex(x, y, z))
    end
    cubes
end

function sides(cube, cubes)
    6 - sum(NEIGHBOR_DELTAS) do delta
        (cube + delta) ∈ cubes
    end
end

function day18_part1(cubes)
    exposed_sides = 0
    for cube in cubes
        exposed_sides += sides(cube, cubes)
    end
    exposed_sides
end

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

function add_neighbors!(neighbors, cur_coord, box, air_cubes, cubes)
    for delta in NEIGHBOR_DELTAS
        new_coord = cur_coord + delta
        # Skip invalid or already seen points
        cur_coord ∉ box && continue
        (new_coord ∈ cubes || new_coord ∈ air_cubes) && continue

        # Otherwise add point to list to be visited
        push!(neighbors, new_coord)
    end
end

function flood_fill(min_coord, max_coord, cubes)
    air_cubes = Set{CartesianIndex{3}}()
    box = min_coord:max_coord
    cur_coord = min_coord

    neighbors = CartesianIndex{3}[]
    add_neighbors!(neighbors, cur_coord, box, air_cubes, cubes)
    while length(neighbors) >= 1
        push!(air_cubes, cur_coord)
        cur_coord = pop!(neighbors) 
        add_neighbors!(neighbors, cur_coord, box, air_cubes, cubes)
    end

    air_cubes 
end

function sides_p2(cube, air_cubes)
    sum(NEIGHBOR_DELTAS) do delta
        (cube + delta) ∈ air_cubes
    end
end

function day18_part2(cubes)
    # Determine non-enclosed air cubes
    (min_coord, max_coord) = CartesianIndex.(get_boundaries(cubes))
    air_cubes = flood_fill(min_coord, max_coord, cubes)

    # Calculate exposed sides based on air cubes
    exposed_sides = 0
    for cube in cubes
        exposed_sides += sides_p2(cube, air_cubes)
    end

    exposed_sides
end
