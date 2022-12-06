function parse_day4(inp_str)
    map(eachsplit(inp_str, '\n')) do line
        segments = split(line, ',')
        (segments[1], segments[2]) .|> to_range
    end
end

function to_range(range_str)
    parts = split(range_str, '-')
    parse(Int, parts[1]):parse(Int, parts[2])
end

function  day4_part1(inp)
    sum(inp) do (s1, s2)
        s1 ⊆ s2 || s2 ⊆ s1
    end
end

function  day4_part2(inp)
end
