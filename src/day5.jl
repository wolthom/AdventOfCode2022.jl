function parse_day5(inp_str)
    (stacks_str, movements_str) = split(inp_str, "\n\n")

    stacks = [Vector{Char}() for _ in 1:9]  
    foreach(eachsplit(stacks_str, '\n')) do row
        for (idx, el) in enumerate(get_stack_entries(row))
            (el ∈ '1':'9' || el == ' ') && continue # Skip invalid crates
            pushfirst!(stacks[idx], el)
        end
    end
    stacks
end

function get_stack_entries(row)
    num_chars = length(row)
    (row[i] for i in 2:4:num_chars) # Generator of stack entries
end

function  day5_part1(inp)
end

function  day5_part2(inp)
end
