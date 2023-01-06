@enum Field Empty Floor Rock

@enum Orientation Left Right Top Bottom

const Movement = Union{Char, Int}

const MOVEMENT_REGEX = r"(\d+|\w)"

function show_field(field)
    out = IOBuffer();
    for row in eachrow(field)
        for el in row
            c = el == Floor ? '.' :
                el == Rock ? '#' : ' '
            write(out, c)
        end
        write(out, '\n')
    end
    s = String(take!(out))
    println(s)
end

function parse_char(c)
    c == '.' ? Floor :
        c == '#' ? Rock : Empty
end

function parse_day22(inp_str)
    # Separate parts of the input
    field_str, movements_str = split(inp_str, "\n\n")

    # Parse grove field
    field_rows = map(eachsplit(field_str, '\n')) do line
        permutedims([parse_char(c) for c in line])
    end 
    max_cols = reduce((val, vec) -> max(val, length(vec)), field_rows; init=0)
    field = fill(Empty, length(field_rows), max_cols)
    for (i, vec) in enumerate(field_rows)
        for (j, element) in enumerate(vec)
            field[i, j] = element
        end
    end

    # Parse instruction
    movements = Vector{Movement}()
    for m in eachmatch(MOVEMENT_REGEX, movements_str)
        s = m[1]
        if length(s) == 1
            push!(movements, only(s))
        else
            push!(movements, parse(Int, s))
        end
    end

    return field, movements
end

struct Pos
    x::Int
    y::Int
    o::Orientation
end

function first_pos(field)
    Pos(size(field, 1), 1, Right)
end

function day22_part1(inp)
end

function day22_part2(inp)
end
