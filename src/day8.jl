using IterTools

function parse_day8(inp_str)
    vecs = map(eachsplit(chomp(inp_str), '\n')) do line
        parse.(Int8, collect(line))
    end
    reduce(hcat, vecs)' |> collect
end

function scan_lines(tree_idx, first_idx, last_idx)
    # Rev to ensure inside-out iteration
    left_idxs = CartesianIndex(tree_idx[1], first_idx[2]):CartesianIndex(tree_idx[1], tree_idx[2]-1) |> reverse
    top_idxs = CartesianIndex(first_idx[1], tree_idx[2]):CartesianIndex(tree_idx[1]-1, tree_idx[2]) |> reverse
    bottom_idxs = CartesianIndex(tree_idx[1]+1, tree_idx[2]):CartesianIndex(last_idx[1], tree_idx[2])
    right_idxs = CartesianIndex(tree_idx[1], tree_idx[2]+1):CartesianIndex(tree_idx[1], last_idx[2])
    (left_idxs, top_idxs, bottom_idxs, right_idxs)
end

function day8_part1(inp)
    # Allocate map that tracks visibility
    vis_map = fill(false, size(inp))

    # Calculate relevant rectangle of trees
    #   Outer trees are guaranteed to be visible => no checking required
    all_idxs = CartesianIndices(inp)
    first_idx, last_idx = (first(all_idxs), last(all_idxs))
    unit_step = one(first_idx)
    candidate_idxs = (first_idx + unit_step) : unit_step : (last_idx - unit_step)

    # For each tree, check in a line scan if it is visible
    for tree_idx in candidate_idxs
        (left_idxs, top_idxs, bottom_idxs, right_idxs) = scan_lines(tree_idx, first_idx, last_idx)
        covers = x -> inp[x] >= inp[tree_idx]
        vis_map[tree_idx] = (any(covers, left_idxs) && any(covers, top_idxs) && any(covers, bottom_idxs) && any(covers, right_idxs))
    end
    length(vis_map) - sum(vis_map)
end

