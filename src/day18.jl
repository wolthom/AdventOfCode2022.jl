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
    abs(cube1[1] - cube2[1]) + 
    abs(cube1[2] - cube2[2]) + 
    abs(cube1[3] - cube2[3])
end

function mark_surfaces!(cube1, cube2)
    delta = (
              cube1.x - cube2.x,
              cube1.y - cube2.y,
              cube1.z - cube2.z,
    )
    # Mark bit for covered field
    (_, offset1) = CUBE_COVER_MASKS[findfirst(delta)]
    cube1.covered[] = cube1.covered[] | (1 << offset1)

    # Mark bit for covered field
    (_, offset2) = CUBE_COVER_MASKS[findfirst((-1) .* delta)]
    cube2.covered[] = cube2.covered[] | (1 << offset2)
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
end

function day18_part2(inp)
end
