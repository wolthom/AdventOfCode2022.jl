@enum OpCode Add Mul Exp

struct Operation
    c::OpCode
    n::Int
end

# TODO: Make op more elegant to get code type stable
struct Monkey
    items::Vector{Int}
    op::Operation
    cond::Int
    pos_target::Int
    neg_target::Int
    activities::Base.RefValue{Int}
end

function parse_day11(inp_str)
    map(parse_monkey, eachsplit(inp_str, "\n\n"))
end

function parse_monkey(monkey_str)
    (_, items_str, op_str, cond_str, pos_str, neg_str) = split(monkey_str, '\n'; limit = 6)
    
    items = map(Base.Fix1(parse, Int), eachsplit(@view(items_str[19:end]), ", "))
    op = parse_operation(op_str)
    cond = parse(Int, @view(cond_str[22:end]))
    pos = parse(Int, @view(pos_str[30:end])) + 1
    neg = parse(Int, @view(neg_str[31:end])) + 1
    Monkey(items, op, cond, pos, neg, Ref(0))
end

function parse_operation(op_str)
    parts = split(@view(op_str[20:end]), ' ')
    parts[1] == parts[3] && return Operation(Exp, 0)

    n = parse(Int, parts[3])
    parts[2] == "+" ? Operation(Add, n) : Operation(Mul, n)
end

function apply_op(op, level)
    op.c == Exp ? level * level : 
        op.c == Add ? (level + op.n) : (level * op.n)
end

function show_monkeys(inp)
    println()
    for (idx, m) in enumerate(inp)
        println("Monkey $(idx): $(m.items)")
    end
    println()
end

function run_rounds!(monkeys, reducer=identity; rounds=20)
    for _ in 1:rounds
        # Each monkey's round
        for (idx, monkey) in enumerate(monkeys)
            pos_target = monkeys[monkey.pos_target]
            neg_target = monkeys[monkey.neg_target]
            
            # Each item of a monkey
            while !isempty(monkey.items)
                monkey.activities[] += 1
                worry_level = apply_op(monkey.op, popfirst!(monkey.items))
                new_level = reducer(worry_level)
                new_level % monkey.cond == 0 ? push!(pos_target.items, new_level) : push!(neg_target.items, new_level)
            end
        end
    end
end

function day11_part1(inp)
    inp = deepcopy(inp)

    # Reducing lambda: Integer-division by 3
    reducer(l) = div(l, 3)

    # Apply 20 iterations
    run_rounds!(inp, reducer; rounds=20)

    # Retrieve result
    sort!(inp; by=x->x.activities[])
    inp[end].activities[] * inp[end-1].activities[]
end


function day11_part2(inp)
    inp = deepcopy(inp)

    # Reducing lambda: Maximum modulus wrap-around
    max_mod = prod(m -> m.cond, inp)
    reducer(l) = l % max_mod

    # Apply 10_000 iterations
    run_rounds!(inp, reducer; rounds=10_000)

    # Retrieve result
    sort!(inp; by=x->x.activities[])
    inp[end].activities[] * inp[end-1].activities[]
end

