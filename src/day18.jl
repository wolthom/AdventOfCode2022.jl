struct Cube
    x::Int
    y::Int
    z::Int
    covered::Base.RefValue{UInt8} # Bitmask 0..5 to track covered sides
end

const CUBE_COVER_MASKS = (
    (1, 0, 0),
    (-1, 0, 0),
    (0, 1, 0),
    (0, -1, 0),
    (0, 0, 1),
    (0, 0, -1),
)

const cube_line_regex = r"(\d*),(\d*),(\d*)"

function parse_day18(inp_str)
    map(eachsplit(chomp(inp_str), '\n')) do line
        x_str, y_str, z_str = match(cube_line_regex, line)
        x, y, z = (parse(Int, x_str), parse(Int, y_str), parse(Int, y_str))
        Cube(x, y, z, Ref(UInt8(0)))
    end |> collect
end

function l1_norm(cube1, cube2)
    abs(cube1.x - cube2.x) + 
    abs(cube1.y - cube2.y) + 
    abs(cube1.z - cube2.z)
end

function mark_surfaces!(cube1, cube2)
    delta = (
              cube1.x - cube2.x,
              cube1.y - cube2.y,
              cube1.z - cube2.z,
    )
    # Mark bit for covered field of cube 1
    idx = findfirst(==(delta), CUBE_COVER_MASKS)
    offset = idx - 1
    cube1.covered[] = cube1.covered[] | (0x1 << offset)

    # Mark bit for covered field of cube 2
    idx = findfirst(==((-1) .* delta), CUBE_COVER_MASKS)
    offset = idx - 1
    cube2.covered[] = cube2.covered[] | (0x1 << offset)
end

function day18_part1(cubes)
    for i in 1:length(cubes)
        for j in 1:length(cubes)
            i == j && continue

            cube1 = cubes[i]
            cube2 = cubes[j]
            l1_norm(cube1, cube2) != 1 && continue
            mark_surfaces!(cube1, cube2)
        end
    end
    length(cubes) * 6 - sum(cubes) do cube
        count_ones(cube.covered[])
    end
end

function day18_part2(inp)
end
