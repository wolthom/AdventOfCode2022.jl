function parse_day10(inp_str)
    map(eachsplit(inp_str, '\n')) do line
        line[1] == 'n' ? (0, 1) : (parse(Int64, @view line[6:end]), 2)
    end |> collect |> reverse
end

function day10_part1(inp)
    inp = copy(inp)

    signal_sum = 0
    reg = 1
    cycle = 0
    cycle_thresh = 20

    while true
        # Break loop after 220 cycles
        cycle_thresh > 220 && break

        # Start next op
        (dr, num_cycles) = pop!(inp)
        cycle += num_cycles

        # Gather signal and move threshold
        if cycle >= cycle_thresh
            signal_sum += cycle_thresh * reg
            cycle_thresh += 40
        end

        # Update register after op
        reg += dr
    end

    signal_sum
end


function day10_part2(inp)
    inp = copy(inp)
    out = IOBuffer()

    reg = 1
    pos_range = max(0, reg-1):min(39, reg+1)
    dr, ctr = (0, 0)

    for cyc in 0:239
        # Pop current iteration
        if ctr == 0
            reg += dr # Apply previous op
            pos_range = max(0, reg-1):min(39, reg+1)
            dr, ctr = pop!(inp) # Retrieve new op
        end

        # Calculate current pixel
        pos = cyc % 40 # ∈ [1, 40]
        
        # Print current pixel
        pos ∈ pos_range ? write(out, '#') : write(out, '.')
        pos == 39 && write(out, '\n')

        # Advance cycle counter
        ctr -= 1
    end

    String(take!(out))
end
