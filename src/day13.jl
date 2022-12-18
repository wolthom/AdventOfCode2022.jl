function parse_day13(inp_str)
    chunks = eachsplit(chomp(inp_str), "\n\n")
    map(chunks) do chunk
        eval.(Meta.parse.(split(chunk, '\n')))
    end
end

compare(a::Int, b::Int) = sign(a - b)
compare(a::Int, b::Vector) = compare([a], b)
compare(a::Vector, b::Int) = compare(a, [b])

function compare(a::Vector, b::Vector)
    for i in 1:min(length(a), length(b))
        x = compare(a[i], b[i])
        x == 0 || return x
    end
    return sign(length(a) - length(b))
end

function day13_part1(inp)
    s = 0
    for (i, pair) in enumerate(inp)
        a, b = pair
        if compare(a, b) <= 0
            s += i
        end
    end
    return s
end

function day13_part2(inp)
end
