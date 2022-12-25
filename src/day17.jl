const SPAWN_X = 3
const FIELD_WIDTH = 7
const NUM_ITERATIONS = 2023
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
    max_height = 4 * NUM_ITERATIONS + 4
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

function day17_part1(state)
    state = deepcopy(state)
    for (i, shape) in enumerate(Iterators.cycle(SHAPES))
        # Spawn new rock
        start_coord = (state.spawn_height-1, SPAWN_X-1)
        rock = shift_rock(shape, start_coord)
        
        # Make rock fall into place
        move_rock!(rock, state)
        i == 2022 && break
    end
    maximum(idx -> idx[1], state.max_coords)
end

function day17_part2(inp)
end
