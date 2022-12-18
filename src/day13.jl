function parse_day13(inp_str)
    chunks = eachsplit(chomp(inp_str), "\n\n")
    map(chunks) do chunk
        eval.(Meta.parse.(split(chunk, '\n')))
    end
end
