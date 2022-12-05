function parse_day3(inp_str)
    # Split input into separate rucksacks
    eachsplit(inp_str, "\n") |> collect
end

function priority(item)
    # 'a'-'z' => 1..26
    # 'A'-'Z' => 27..52
    Int(item) - Int('a') + 1 + isuppercase(item) * 58
end

function day3_part1(inp)
    map(inp) do rucksack
        idx = div(length(rucksack), 2)
        @views p1, p2 = (rucksack[begin:idx], rucksack[idx+1:end])
        intersect(p1, p2) |> only |> priority
    end |> sum
end

function day3_part2(inp)
    map(Iterators.partition(inp, 3)) do rucksacks
        intersect(rucksacks...) |> only |> priority
    end |> sum
end
