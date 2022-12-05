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
    comp1, comp2 = Set{Char}(), Set{Char}()
    out = 0
    for rucksack in inp
        idx = div(length(rucksack), 2)
        @views p1, p2 = (rucksack[begin:idx], rucksack[idx+1:end])

        union!(comp1, p1)
        union!(comp2, p2)
        
        out += intersect(comp1, comp2) |> only |> priority
        empty!(comp1)
        empty!(comp2)
    end
    out
end

function day3_part2(inp)
    items = Set{Char}()
    out = 0
    for rucksacks in Iterators.partition(inp, 3)
        (r1, r2, r3) = rucksacks

        union!(items, r1)
        intersect!(items, r2, r3)

        out += only(items) |> priority
        empty!(items)
    end
    out
end
