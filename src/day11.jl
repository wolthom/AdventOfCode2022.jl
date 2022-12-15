struct Monkey
    items::Vector{Int}
    op::Function
    cond::Int
    pos_target::Int
    neg_target::Int
end

function parse_day11(inp_str)
    map(parse_monkey, eachsplit(inp_str, "\n\n"))
end

function parse_monkey(monkey_str)
    (_, items_str, op_str, cond_str, pos_str, neg_str) = split(monkey_str, '\n'; limit = 6)
    
    items = map(Base.Fix1(parse, Int), eachsplit(@view(items_str[19:end]), ", "))
    op = Meta.parse("old -> $(@view(op_str[20:end]))") |> Meta.eval
    cond = parse(Int, @view(cond_str[22:end]))
    pos = parse(Int, @view(pos_str[30:end])) + 1
    neg = parse(Int, @view(neg_str[31:end])) + 1
    Monkey(items, op, cond, pos, neg)
end

function day11_part1(inp)
    inp = deepcopy(inp)
    # Track activity
    monkey_activities = fill(0, length(inp))

    # Run 20 rounds
    for _ in 1:20
        # Each monkey's round
        for (idx, monkey) in enumerate(inp)
            pos_target = inp[monkey.pos_target]
            neg_target = inp[monkey.neg_target]
            
            # Each item of a monkey
            while !isempty(monkey.items)
                monkey_activities[idx] += 1
                worry_level = popfirst!(monkey.items) |> monkey.op
                new_level = div(worry_level, 3)
                new_level % monkey.cond == 0 ? push!(pos_target.items, new_level) : push!(neg_target.items, new_level) end
        end
        # show_monkeys(inp)
    end

    sort!(monkey_activities)
    reduce(*, last(monkey_activities, 2))
end

function show_monkeys(inp)
    println()
    for (idx, m) in enumerate(inp)
        println("Monkey $(idx): $(m.items)")
    end
    println()
end

function day11_part2(inp)
    inp = deepcopy(inp)
    # Track activity
    monkey_activities = fill(0, length(inp))
    max_mod = prod(map(m -> m.cond, inp))

    # Run 10_000 rounds
    for _ in 1:10_000
        # Each monkey's round
        for (idx, monkey) in enumerate(inp)
            pos_target = inp[monkey.pos_target]
            neg_target = inp[monkey.neg_target]
            
            # Each item of a monkey
            while !isempty(monkey.items)
                monkey_activities[idx] += 1
                worry_level = popfirst!(monkey.items) |> monkey.op
                new_level = worry_level % max_mod
                new_level % monkey.cond == 0 ? push!(pos_target.items, new_level) : push!(neg_target.items, new_level)
            end
        end
    end

    sort!(monkey_activities)
    reduce(*, last(monkey_activities, 2))
end
