using Chain

function parse_day12(inp_str)
    # Create Char matrix
    char_map = reduce(hcat, map(collect, eachsplit(inp_str, '\n')))

    # Find start and end index
    sidx, eidx = find_positions(char_map)

    # Create Int matrix
    field_map = map(field_val, char_map)

    (sidx, eidx, field_map)
end

function find_positions(char_map)
    sidx, eidx = (CartesianIndex(0, 0), CartesianIndex(0, 0))

    for idx in CartesianIndices(char_map)
        if char_map[idx] == 'S'
            sidx = idx
        elseif char_map[idx] == 'E'
            eidx = idx
        end
    end

    (sidx, eidx)
end

function field_val(c)
    c ∈ 'a':'z' && return c - 'a'
    c == 'S' && return 'a' - 'a'
    c == 'E' && return 'z' - 'a'
end

function day12_part1(inp)
end

function day12_part2(inp)
end
