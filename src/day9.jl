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

function day9_part1(inp)
    rope = fill((0,0), 2)
    positions = Set{Tuple{Int, Int}}()
    push!(positions, last(rope))

    foreach(inp) do mov
        move!(rope, mov, positions)
    end

    length(positions)
end

function move!(rope, mov, hist)
    dx, dy = mov.dir

    for _ in 1:mov.steps
        head = rope[1]
        rope[1] = (head[1] + dx, head[2] + dy)
        reposition_segments!(rope)
        push!(hist, last(rope))
    end
    rope
end

function reposition_segments!(rope)
    for idx in 1:length(rope)-1
        head, tail = (rope[idx], rope[idx + 1])

        diff = head .- tail
        dist = hypot(diff[1], diff[2])

        # Return if no tail movement is required
        dist < 2.0 && return tail

        # Calculate (dx, dy)-step of tail
        step = @. oneunit(diff) * sign(diff)    

        # New tail
        rope[idx + 1] = tail .+ step
    end
    rope
end

function day9_part2(inp)
    rope = fill((0,0), 10)
    positions = Set{Tuple{Int, Int}}()
    push!(positions, last(rope))

    foreach(inp) do mov
        move!(rope, mov, positions)
    end

    length(positions)
end
