# @enum Field Empty Floor Rock

const Movement = Union{Char, Int}

function parse_line(line)

end

function parse_day22(inp_str)
    field_str, movements_str = split(inp_str, "\n\n")
    field = map(eachsplit(field_str, '\n')) do line

    end |> hcat
    return field
end

function day22_part1(inp)
end

function day22_part2(inp)
end
