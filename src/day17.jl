const SPAWN_X = 3
const FIELD_WIDTH = 7
const NUM_ROCKS_P1 = 2022
const NUM_ROCKS_P2 = 1_000_000_000_000
# Collection of all shapes in "local" coordinates
# (0, 0) -> Lower left point
# Shorter shapes are filled with a duplicated coordinate for type stability
const SHAPES = (
    ((1, 1), (1, 2), (1, 3), (1, 4), (1, 1)),
    ((2, 1), (1, 2), (2, 2), (3, 2), (2, 3)),
    ((1, 1), (1, 2), (1, 3), (2, 3), (3, 3)),
    ((1, 1), (2, 1), (3, 1), (4, 1), (1, 1)),
    ((1, 1), (2, 1), (1, 2), (2, 2), (1, 1)),
)

mutable struct MapState
    max_coords::Vector{Int}
    spawn_height::Int
    current_idx::Int
    currents::Vector{Char}
    field::BitMatrix
end

function parse_day17(inp_str)
    # Maximum number of vertically stacked I bars
    max_height = 4 * NUM_ROCKS_P1 + 4
    field = falses(max_height, FIELD_WIDTH)
    state = MapState(zeros(FIELD_WIDTH), 4, 1, collect(chomp(inp_str)), field)
    state
end

function shift_rock(rock, delta)
    ntuple(length(rock)) do idx
        (rock[idx][1] + delta[1], rock[idx][2] + delta[2])
    end
end

function horizontal_is_valid(rock, field)
    for idx in rock
        ((idx[2] < 1) || (idx[2] > FIELD_WIDTH) || field[idx[1], idx[2]]) && return false
    end
    true
end

function vertical_is_valid(rock, field)
    for idx in rock
        ((idx[1] < 1) || field[idx[1], idx[2]]) && return false
    end
    true
end

function move_rock!(rock, state) 
    while true
        # Retrieve current horizontal movement
        mov = state.currents[state.current_idx]
        state.current_idx = mod1(state.current_idx + 1, length(state.currents))
        delta = mov == '<' ? (0, -1) : (0, 1)

        # Try to apply vertical movement
        new_rock_pos = shift_rock(rock, delta)
        if horizontal_is_valid(new_rock_pos, state.field)
            rock = new_rock_pos
        end

        # Update vertical movement
        new_rock_pos = shift_rock(rock, (-1, 0))
        # Mark current rock positions if any potential new position is already covered or the floor is reached
        if !vertical_is_valid(new_rock_pos, state.field)
            foreach(rock) do idx
                state.field[idx[1], idx[2]] = true
                state.max_coords[idx[2]] = max(state.max_coords[idx[2]], idx[1])
                state.spawn_height = maximum(state.max_coords) + 4
            end
            break
        else
            rock = new_rock_pos
        end
    end
end

function max_height(max_coords)
    maximum(idx -> idx[1], max_coords)
end

function day17_part1(state)
    state = deepcopy(state)
    for (i, shape) in enumerate(Iterators.cycle(SHAPES))
        # Spawn new rock
        start_coord = (state.spawn_height-1, SPAWN_X-1)
        rock = shift_rock(shape, start_coord)
        
        # Make rock fall into place
        move_rock!(rock, state)
        i == NUM_ROCKS_P1 && break
    end
    max_height(state.max_coords)
end

function calculate_relative_heights(max_coords)
    max_height = maximum(idx -> idx[1], max_coords)
    ntuple(Val(7)) do idx
        max_height - max_coords[idx]
    end
end

function get_cycle_state(state, rock_idx)
    shape_idx = mod1(rock_idx, length(SHAPES))
    current_idx = state.current_idx
    relative_heights = calculate_relative_heights(state.max_coords)
    (shape_idx, current_idx, relative_heights)
end

const CycleState = Tuple{Int, Int, NTuple{7, Int}}

function day17_part2(state)
    state = deepcopy(state)
    cache = Dict{CycleState, Tuple{Int, Int}}()

    # Height gain derived from not-run cycles
    cycle_add = 0
    # Number of iterations to actually run
    max_i = NUM_ROCKS_P2

    for (i, shape) in enumerate(Iterators.cycle(SHAPES))
        # Spawn new rock
        start_coord = (state.spawn_height-1, SPAWN_X-1)
        rock = shift_rock(shape, start_coord)
        
        # Make rock fall into place
        move_rock!(rock, state)
        i == max_i && break

        # Skip caching after cyclicity was found
        max_i != NUM_ROCKS_P2 && continue

        # Cache current rock count and height based on cyclicity state
        cycle_state = get_cycle_state(state, i)
        if haskey(cache, cycle_state)
            (prev_i, prev_max_height) = cache[cycle_state]
            cur_max_height = max_height(state.max_coords)

            # Calculate how many cycles to skip / how many iterations are missing
            num_cycles, remaining_iterations = divrem((NUM_ROCKS_P2 - i), (i - prev_i))
            max_i = i + remaining_iterations

            # Store height added during full cycles
            cycle_add = num_cycles * (cur_max_height - prev_max_height)
            continue
        end
        cache[cycle_state] = (i, max_height(state.max_coords))
    end
    max_height(state.max_coords) + cycle_add
end
