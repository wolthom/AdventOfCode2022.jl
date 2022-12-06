using IterTools

function parse_day5(inp_str)
    (stacks_str, movements_str) = split(inp_str, "\n\n")

    stacks = [Vector{Char}() for _ in 1:9]  
    foreach(eachsplit(stacks_str, '\n')) do row
        for (idx, el) in enumerate(get_stack_entries(row))
            (el ∈ '1':'9' || el == ' ') && continue # Skip invalid crates
            pushfirst!(stacks[idx], el)
        end
    end

    movements = [get_movement(row) for row in eachsplit(movements_str, '\n')]
    (stacks, movements)
end

function get_stack_entries(row)
    num_chars = length(row)
    (row[i] for i in 2:4:num_chars) # Generator of stack entries
end

function get_movement(row)
    parts = split(row, ' ')
    ntuple(idx -> parse(Int, parts[2*idx]), 3)
end

function  day5_part1(stacks, movements)
    stacks = deepcopy(stacks)

    # Apply movement operations
    for (n, from, to) in movements
        from_stack = stacks[from]
        to_stack = stacks[to]
        for _ in 1:n
            push!(to_stack, pop!(from_stack))
        end
    end

    # Create output string
    map(stacks) do stack
        stack[end]
    end |> Base.Fix2(join, "")
end

function  day5_part2(stacks, movements)
    stacks = deepcopy(stacks)

    # Apply movement operations
    for (n, from, to) in movements
        from_stack = stacks[from]
        to_stack = stacks[to]
        range = (length(from_stack)-n+1):length(from_stack)
        @views crates = from_stack[range] 
        append!(to_stack, crates)
        deleteat!(from_stack, range)
    end

    # Create output string
    map(stacks) do stack
        stack[end]
    end |> Base.Fix2(join, "")
end
