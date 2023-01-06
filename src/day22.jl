using Accessors

@enum Field Empty Floor Rock

@enum Orientation Top=1 Left=2 Bottom=3 Right=4

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
        if all(isdigit, s)
            push!(movements, parse(Int, s))
        else
            push!(movements, only(s))
        end
    end

    return field, movements
end

struct Pos
    x::Int
    y::Int
    or::Orientation
end

function first_pos(field)
    Pos(size(field, 1), 1, Right)
end

function rotate(pos, dir)
    # Calculate new orientation
    dir_val = dir == 'R' ? -1 : 1
    or_val = Int(pos.or)
    new_or_val = mod1(or_val + dir_val, 4)

    # Return new position
    @set pos.or = Orientation(new_or_val)
end

function apply_movement(pos, mov, field)
    # Short circuit orientation change
    if mov isa Char
        return rotate(Pos, mov)
    end
end

function day22_part1(inp)

end

function day22_part2(inp)
end
