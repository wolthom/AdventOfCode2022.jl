function parse_day8(inp_str)
    vecs = map(eachsplit(chomp(inp_str), '\n')) do line
        parse.(Int8, collect(line))
    end
    reduce(hcat, vecs)' |> collect
end

function day8_part1(inp)
end

function day8_part2(inp)
end
