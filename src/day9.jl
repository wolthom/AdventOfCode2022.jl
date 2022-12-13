using Accessors

struct Pos
    x::Int
    y::Int
end

struct Mov
    dir::Tuple{Int, Int}
    steps::Int64
end

function parse_day9(inp_str)
    map(to_mov, eachsplit(inp_str, '\n')) |> collect
end

function to_mov(line)
    c = line[1]
    dir = c == 'R' ? (1, 0) :
            c == 'L' ? (-1, 0) :
            c == 'U' ? (0, 1) : (0, -1)
    steps = parse(Int64, split(line, ' ')[2])
    Mov(dir, steps)
end


function day9_part2(inp)
end
