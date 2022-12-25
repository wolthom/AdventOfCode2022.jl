const Point3D = Tuple{Int, Int, Int}

const NEIGHBOR_DELTAS = (
    (1, 0, 0),
    (-1, 0, 0),
    (0, 1, 0),
    (0, -1, 0),
    (0, 0, 1),
    (0, 0, -1),
)

const cube_line_regex = r"(\d*),(\d*),(\d*)"

function parse_day18(inp_str)
    cubes = Set{Point3D}()
    foreach(eachsplit(chomp(inp_str), '\n')) do line
        x_str, y_str, z_str = match(cube_line_regex, line)
        x, y, z = (parse(Int, x_str), parse(Int, y_str), parse(Int, z_str))
        push!(cubes, (x, y, z))
    end
    cubes
end

function sides(cube, cubes)
end

function day18_part1(cubes)
    exposed_sides = 0
    for cube in cubes

    end
end

function day18_part2(inp)
end
