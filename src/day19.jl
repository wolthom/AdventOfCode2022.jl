using Accessors

@enum Resources Ore=1 Clay=2 Obsidian=3 Geode=4

const RobotCost = NTuple{3, Int16}

struct BluePrint
    id::Int16
    costs::NTuple{4, RobotCost}
end

const BLUEPRINT_REGEX = r"(\d+)"

struct MiningState
    resources::NTuple{3, Int16}
    robots::NTuple{3, Int16}
    geodes::Int
    mins::Int
end

function MiningState()
    MiningState(
        (0, 0, 0),
        (1, 0, 0), # 1 Ore robot at the beginning
        0, 
        24,
    )
end

function MiningState(mins)
    MiningState(
        (0, 0, 0),
        (1, 0, 0), # 1 Ore robot at the beginning
        0, 
        mins,
    )
end

function parse_day19(inp_str)
    parse_match(m) = parse(Int16, m[1])
    map(eachsplit(chomp(inp_str), '\n')) do line
        nums = map(parse_match, eachmatch(BLUEPRINT_REGEX, line))
        BluePrint(
            nums[1],
            (
             (nums[2], 0, 0), # Ore robot cost
             (nums[3], 0, 0), # Clay robot cost
             (nums[4], nums[5], 0), # Obsidian robot cost
             (nums[6], 0, nums[7]), # Geode robot cost
            )
        )
    end |> collect
end

# TODO: Debug upper bound
function upper_bound(state, costs)
    cost = costs[Int(Geode)][Int(Obsidian)]
    geodes = state.geodes
    obsidian = state.resources[Int(Obsidian)]
    rate = state.robots[Int(Obsidian)]

    reducer((geodes, obsidian, rate), mins) = begin
        # Build geode robots whenever enough obsidian is available
        if obsidian >= cost
            (geodes + mins, obsidian + rate - cost, rate)
        # Assume obsidian robots can always be produced
        else
            (geodes, obsidian + rate, rate + 1)
        end
    end
    
    # Apply for remaining time
    res = reduce(reducer, (state.mins-1):-1:0; init=(geodes, obsidian, rate))
    res[1]
end

function is_relevant(move_idx, state, costs, max_costs, max_geodes)
    # Check if robot is still required
    ((move_idx != 4) && (state.robots[move_idx] > max_costs[move_idx])) && return false

    # Check if move can actually outperform current max
    # Smart approximation of the upper bound:
    #   Assume infinite ore and clay, but not obsidian
    #   Calculate how many Geodes will be possible this way
    #   See: https://github.com/Crazytieguy/advent-of-code/blob/master/2022/src/bin/day19/main.rs#L187-L210
    upper_bound(state, costs) <= max_geodes && return false

    # Otherwise move is relevant
    true
end

# TODO: Fix this
function calculate_next_state(move_idx, state, costs)
    out::Union{Nothing, MiningState} = nothing

    resource_eltype = eltype(state.resources)
    geodes = state.geodes
    rates = state.robots
    robot_costs = costs[move_idx]
    
    # Bail if a required resource is not being produced
    for idx in 1:length(robot_costs)
        ((robot_costs[idx] != 0) && (rates[idx] == 0)) && return out
    end

    # Find timepoint when sufficient resources are available
    new_resources = state.resources
    new_robots = state.robots

    rem = state.mins
    # 1. Check if robot can be produced at current times
    # 2. Calculate new resources
    # 3. Update time and repeat
    while any(new_resources .< robot_costs)
        new_resources = new_resources .+ rates
        rem -= 1
        # @show rates, new_resources, rem

    end

    # Bail if robot will not be available early enough to produce resources
    rem <= 1 && return out

    # Build robot and advance time
    rem -= 1
    new_resources = new_resources .- robot_costs

    # Whenever a new geode robot is manufactured, directly add its entire production
    if move_idx == Int(Geode)
        geodes += rem
    else
        @reset new_robots[move_idx] = new_robots[move_idx] + resource_eltype(1)
    end
   
    out = MiningState(new_resources .+ rates, new_robots, geodes, rem)

    out
end

function run_simulation!(start_state, bp)
    max_geodes = 0

    # Debug data to track
    max_len = 0
    num_states = 0

    max_costs = NTuple{3, Int16}(maximum(x->x[i], bp.costs) for i in 1:length(start_state.resources))

    # Emulate depth-first search by keeping different remaining times in separate stacks
    states = [ MiningState[] for _ in 1:start_state.mins ]

    push!(states[start_state.mins], start_state)
    # Keep iterating while relevant branches exist
    pred(s) = length(s) > 0
    while any(pred, states)
        idx = findfirst(pred, states)

        # Retrieve current branch to explore (preferring branches with a smaller number of remaining minutes)
        state = pop!(states[idx])
        num_states += 1
        # Update Debug data
        max_geodes = max(max_geodes, state.geodes)
        max_len = max(max_len, length(states))

        # Add branches to explore
        for move_idx in Int.((Ore, Clay, Obsidian, Geode))
            next_state = calculate_next_state(move_idx, state, bp.costs)
            # Skip if desired state is unreachable
            isnothing(next_state) && continue

            # Skip irrelevant moves
            !is_relevant(move_idx, next_state, bp.costs, max_costs, max_geodes) && continue

            push!(states[next_state.mins], next_state)
        end
    end

    # Report Debug data
    # @show max_len, num_states

    max_geodes
end

function day19_part1(blueprints)
    # Store maximum number of identified geodes
    max_geodes = Dict{BluePrint, Int}()
    for blueprint in blueprints
        # @show blueprint
        max_geodes[blueprint] = typemin(Int)
        state = MiningState() 
        max_geodes[blueprint] = run_simulation!(state, blueprint)
        # @show max_geodes[blueprint]
    end

    sum(max_geodes) do (blueprint, geodes)
        blueprint.id * geodes
    end
end

function day19_part2(blueprints)
    # Store maximum number of identified geodes
    max_geodes = Dict{BluePrint, Int}()
    for blueprint in blueprints[1:3]
        # @show blueprint
        max_geodes[blueprint] = typemin(Int)
        state = MiningState(32) 
        max_geodes[blueprint] = run_simulation!(state, blueprint)
        # @show max_geodes[blueprint]
    end

    sum(max_geodes) do (_, geodes)
        geodes
    end
end
