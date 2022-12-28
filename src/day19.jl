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


function upper_bound(state, costs)
    # Extract locally relevant variables
    cost = costs[Int(Geode)][Int(Obsidian)]
    geodes = state.resources[Int(Geode)]
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
    
    res = reduce(reducer, state.mins:-1:0; init=(geodes, obsidian, rate))
    res[1]
end

function is_relevant(move_idx, state, costs, max_costs, max_geodes)
    return true
    # Check if robot is still required
    state.robots[move_idx] >= max_costs[move_idx] && return false
       
    # Check if move can actually outperform current max
    # Smart approximation of the upper bound:
    #   Assume infinite ore and clay, but not obsidian
    #   Calculate how many Geodes will be possible this way
    #   See: https://github.com/Crazytieguy/advent-of-code/blob/master/2022/src/bin/day19/main.rs#L187-L210
    upper_bound(state, costs) <= max_geodes && return false

    # Otherwise move is relevant
    true
end

function calculate_next_state(move_idx, state, costs)
    out::Union{Nothing, MiningState} = nothing

    resource_eltype = eltype(state.resources)
    rates = state.robots
    robot_costs = costs[move_idx]
    
    required_mins = resource_eltype(0)
    for idx in 1:3 # Geodes are never a resource
        cost = robot_costs[idx]
        rate = rates[idx]

        ((cost != 0) && (rate == 0)) && return out
        rate == 0 && continue

        required_mins = max(required_mins, ceil(resource_eltype, cost / rate))
    end
    required_mins > state.mins && return out

    new_resources = state.resources .+ required_mins .* rates
    new_robots = state.robots
    @reset new_robots[move_idx] = new_robots[move_idx] + resource_eltype(1)
   
    out = MiningState(new_resources, new_robots, state.mins - required_mins)

    out
end

function run_simulation!(start_state, bp)
    max_geodes = 0
    # Debug data to track
    max_len = 0
    num_states = 0

    max_costs = NTuple{4, Int16}(maximum(x->x[i], bp.costs) for i in 1:4)
    @reset max_costs[4] = typemax(Int16) # There is no such thing as too many geodes

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
        # TODO: Optimize by 'skipping ahead' for moves
        #       I.e. calculate when this move may be taken and directly calculate that state
        for move_idx in 1:4 
            next_state = calculate_next_state(move_idx, state, bp.costs)
            # Skip if desired state is unreachable
            isnothing(next_state) && continue

            # Skip irrelevant moves
            !is_relevant(move_idx, next_state, bp.costs, max_costs, max_geodes) && continue

            push!(states, next_state)
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
