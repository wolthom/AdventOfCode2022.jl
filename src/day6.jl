function parse_day6(inp_str)
    inp_str
end

function  day6_part1(inp)
    find_n_distinct(inp, 4)
end


function  day6_part2(inp)
    find_n_distinct(inp, 14)
end


function find_n_distinct(seq, n)
    for idx in (1:(length(seq)-n))
        eidx = idx + n - 1
        allunique(@view seq[idx:eidx]) && return eidx
    end
    -1
end
