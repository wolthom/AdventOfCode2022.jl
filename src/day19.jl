using Accessors

@enum Resources Ore=1 Clay=2 Obsidian=3 Geode=4

const RobotCost = NTuple{4, Int16}

struct BluePrint
    id::Int16
    costs::NTuple{4, RobotCost}
end

const BLUEPRINT_REGEX = r"(\d+)"

struct MiningState
    resources::NTuple{4, Int16}
    robots::NTuple{4, Int16}
    mins::Int16
end

function MiningState()
    MiningState(
        (0, 0, 0, 0),
        (1, 0, 0, 0), # 1 Ore robot at the beginning
        24
    )
end

function parse_day19(inp_str)
    parse_match(m) = parse(Int16, m[1])
    map(eachsplit(chomp(inp_str), '\n')) do line
        nums = map(parse_match, eachmatch(BLUEPRINT_REGEX, line))
        BluePrint(
            nums[1],
            (
             (nums[2], 0, 0, 0), # Ore robot cost
             (nums[3], 0, 0, 0), # Clay robot cost
             (nums[4], nums[5], 0, 0), # Obsidian robot cost
             (nums[6], 0, nums[7], 0), # Geode robot cost
            )
        )
    end |> collect
end

function max_achievable(state)
    # At most all geode robots + one robot per remaining minute can generate geodes
    state.resources[Int(Geode)] +
        state.robots[Int(Geode)] * state.mins +
        ceil(Int, state.mins * (state.mins - 1) / 2)
end

function can_build(resources, cost)
    all(resources .>= cost)
end

function still_required(robots, costs, robot)
    # Geode robots are always needed
    if robot == 4 
        # println("Resource: $robot always required")
        return true 
    end
    
    # The robot is still needed if any resource requirements are higher than the current number
    num_producers = robots[robot]
    @inbounds for idx in 1:length(costs)
        cost = costs[idx][robot]  
        # @show num_producers, cost
        if num_producers < cost
            # println("Resource: $robot Still needed for $idx")
            return true
        end
    end

    false
end

function is_relevant(move_idx, state, costs, max_costs)
    # Check if time remains
    state.mins <= 0 && return false


    # Checks for robot-building moves specifically
    if move_idx != 5
        # Check if robot is still required
        state.robots[move_idx] >= max_costs[move_idx] && return false
       
        # Check if sufficient resources for building robot are available
        !all(state.resources .>= costs[move_idx]) && return false
    end
    
    # Check if move can actually outperform current max
    true
end

# TODO: Evaluate whether caching can prune further branches
function run_simulation!(start_state, bp)
    max_geodes = 0
    # Debug data to track
    max_len = 0
    num_states = 0

    mins = 24
    moves = (
        (1, 0, 0, 0), # Add an ore robot
        (0, 1, 0, 0), # Add a clay robot
        (0, 0, 1, 0), # Add geode robot
        (0, 0, 0, 1), # Add an obsidian robot
        (0, 0, 0, 0), # Wait
    )
    max_costs = NTuple{4, Int16}(maximum(x->x[i], bp.costs) for i in 1:4)
    @reset max_costs[4] = typemax(Int16) # There is no such thing as too many geodes

    # With only one state, this performs BFS, DFS would probably be preferable
    # TODO: Emulate DFS by keeping different stacks for each amount of minutes remaining
    states = MiningState[] 
    push!(states, start_state)
    # Keep iterating while relevant branches exist
    while length(states) > 0
        # Retrieve current branch to explore
        state = pop!(states)
        num_states += 1
        max_geodes = max(max_geodes, state.resources[Int(Geode)])
        max_len = max(max_len, length(states))

        # Add branches to explore
        for (move_idx, move) in enumerate(moves)
            # Skip invalid or irrelevant moves from current state
            !is_relevant(move_idx, state, bp.costs, max_costs) && continue

            new_resources = if move_idx != 5 
                state.resources .+ state.robots .- bp.costs[move_idx]
            else
                state.resources .+ state.robots
            end

            new_robots = state.robots .+ move
            new_state = MiningState(new_resources, new_robots, state.mins-1)
            push!(states, new_state)
        end
    end

    @show max_len, num_states

    max_geodes
end

# TODO: Figure out what allocates such a large amount of memory (for 31 blueprints -> 4e10 allocations --> Likely a hot loop)
function day19_part1(blueprints)
    # Store maximum number of identified geodes
    max_geodes = Dict{BluePrint, Int}()
    for blueprint in blueprints
        @show blueprint
        max_geodes[blueprint] = typemin(Int)
        state = MiningState() 
        max_geodes[blueprint] = run_simulation!(state, blueprint)
        @show max_geodes[blueprint]
    end

    sum(max_geodes) do (blueprint, geodes)
        blueprint.id * geodes
    end
end

function day19_part2(inp)
end
