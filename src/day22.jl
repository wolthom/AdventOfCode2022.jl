using Accessors

@enum Field Empty Floor Rock

@enum Orientation Right=1 Bottom=2 Left=3 Top=4

const Movement = Union{Char, Int}

const MOVEMENT_REGEX = r"(\d+|\w)"

function show_field(field, pos)
    # Get marker for position
    marker = pos.or == Right ? '>' :
             pos.or == Bottom ? 'v' :
             pos.or == Left ? '<' : '^'

    out = IOBuffer();
    # Write grove map
    for (i, row) in enumerate(eachrow(field))
        for (j, el) in enumerate(row)
            if CartesianIndex(i, j) == pos.idx
                write(out, marker)
                continue
            end
            c = el == Floor ? '.' :
                el == Rock ? '#' : ' '
            write(out, c)
        end
        write(out, '\n')
    end

    # Output final grove map
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
    idx::CartesianIndex{2}
    or::Orientation
end

function first_pos(field)
    x_idx = 1
    line = @view(field[x_idx, begin:end])
    y_idx = findfirst(==(Floor), line)
    isnothing(y_idx) && throw(DomainError("No valid field found in first line"))

    Pos(CartesianIndex(x_idx, y_idx), Right)
end

function rotate(pos, dir)
    # Calculate new orientation
    dir_val = dir == 'R' ? 1 : -1
    or_val = Int(pos.or)
    new_or_val = mod1(or_val + dir_val, 4)

    # Return new position
    @set pos.or = Orientation(new_or_val)
end

function shift(pos, field)
    # Determine direction to move in
    delta = pos.or == Top ? CartesianIndex(-1, 0) :
            pos.or == Right ? CartesianIndex(0, 1) :
            pos.or == Bottom ? CartesianIndex(1, 0) : CartesianIndex(0, -1)

    # Determine coordinate delta in case of wrap-around
    wrap = pos.or == Top ? CartesianIndex(size(field, 1), 0) :
            pos.or == Right ? CartesianIndex(0, -size(field, 2)) :
            pos.or == Bottom ? CartesianIndex(-size(field, 1), 0) : CartesianIndex(0, size(field, 2))
    
    # Calculate new index including wrap-around
    new_idx = pos.idx + delta
    new_idx += (1 - checkbounds(Bool, field, new_idx)) * wrap
    field[new_idx] != Empty && return @set pos.idx = new_idx

    # Keep moving if current field is empty
    while (field[new_idx] == Empty)
        new_idx = new_idx + delta
        new_idx += (1 - checkbounds(Bool, field, new_idx)) * wrap
    end
    @set pos.idx = new_idx
end

function apply_movement(pos, mov, field)
    # Short circuit orientation change
    if mov isa Char
        return rotate(pos, mov)
    end

    # Retrieve scanline for current movement
    prev_pos = pos
    for _ in 1:mov
        new_pos = shift(prev_pos, field)
        field[new_pos.idx] == Rock && return prev_pos
        prev_pos = new_pos
    end
    prev_pos
end

function day22_part1((field, movements))
    pos = first_pos(field)
    for mov in movements
        pos = apply_movement(pos, mov, field)
    end
    1000 * pos.idx[1] + 4 * pos.idx[2] + Int(pos.or) - 1
end

function day22_part2(inp)
end
