function parse_day20(inp_str)
    map(Base.Fix1(parse, Int), eachsplit(chomp(inp_str), '\n'))
end

function calculate_new_position(pos, prev_idx, new_idx)
    new_pos = pos

    # Elements moved to the left
    if (prev_idx < new_idx) && (pos ∈ (prev_idx+1):new_idx)
        new_pos -= 1
    # Elements moved to the right
    elseif (prev_idx > new_idx) && (pos ∈ (new_idx:(prev_idx-1)))
        new_pos += 1
    # Updated element
    elseif (pos == prev_idx)
        new_pos = new_idx
    end

    new_pos
end

function calculate_new_idx(pos, num, len)
    wrapped_moves = rem(num, len-1)
    new_idx = pos + wrapped_moves
    new_idx ∈ 2:(len-1) && return new_idx

    # Index must be out of range in either direction here
    wrap_offset = new_idx <= 1 ? -1 : 1
    new_idx = mod1(new_idx + wrap_offset, len)
    new_idx
end

function apply_shifts!(nums, positions; num_shifts=1)
    len = length(nums)
    for _ in 1:num_shifts
        for (i, pos) in enumerate(positions)
            # Calculate new index for number
            num = nums[pos]
            num == 0 && continue # No movement occurs
            new_idx = calculate_new_idx(pos, num, len)

            # Remove and reinsert number
            deleteat!(nums, pos)
            insert!(nums, new_idx, num)
            
            # Update affected positions 
            # is_debug() && (display(hcat(positions, calculate_new_position.(positions, Ref(pos), Ref(new_idx)))))
            @. positions = calculate_new_position(positions, pos, new_idx)
            positions[i] = new_idx
        end
    end
    nums
end



function day20_part1(nums)
    nums = copy(nums)
    # Positions of the respective numbers
    positions = collect(1:length(nums))

    apply_shifts!(nums, positions)

    idx = findfirst(==(0), nums)
    !isnothing(idx) && return 0
    target_offsets = [1000, 2000, 3000]

    sum(target_offsets) do offset
        target_idx = mod1(idx + offset, length(nums))
        nums[target_idx]
    end
end

function day20_part2(nums)
    decryption_key = 811589153
    nums = nums .* decryption_key
    # Positions of the respective numbers
    positions = collect(1:length(nums))

    apply_shifts!(nums, positions; num_shifts=10)

    idx = findfirst(==(0), nums)
    !isnothing(idx) && return 0
    target_offsets = [1000, 2000, 3000]

    sum(target_offsets) do offset
        target_idx = mod1(idx + offset, length(nums))
        nums[target_idx]
    end
end
