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
        24,
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
    state.resources[Int(Geode)] + state.robots[Int(Geode)] * state.mins + ceil(Int, (state.mins) * (state.mins - 1) / 2)
end

function can_build(resources, cost)
    all(resources .>= cost)
end

# TODO: Evaluate whether caching can prune further branches
function run_simulation!(max_geodes, state, bp)
    # Update maximum number of geodes if current run has more than before
    if state.resources[Int(Geode)] > max_geodes[bp]
        max_geodes[bp] = state.resources[Int(Geode)]
    end

    # Stop simulation if time is over
    state.mins <= 0 && return
    # TODO: Improve heuristic for when this branch should terminated
    # Cancel current run if maximum achievable number of geodes can't surpass current maximum
    if max_achievable(state) <= max_geodes[bp]
        return
    end

    # Try to get a new robot
    for robot in (Geode, Obsidian, Clay, Ore)
        robot = Int(robot)
        # Skip if it cannot be built
        !can_build(state.resources, bp.costs[robot]) && continue
        # TODO: Skip robots that don't need to be built anymore

        # Build robot and subtract cost / generate resources
        new_robots = state.robots
        @reset new_robots[robot] += 1
        new_resources = state.resources .- bp.costs[robot] .+ state.robots
        new_state = MiningState(new_resources, new_robots, state.mins-1)

        # Run new simulation and potentially update max geodes
        run_simulation!(max_geodes, new_state, bp)
    end

    # Otherwise just update resources based on current robots
    new_resources = state.resources .+ state.robots 
    @reset state.resources = new_resources
    @reset state.mins -= 1
    run_simulation!(max_geodes, state, bp)
end

function day19_part1(blueprints)
    # Store maximum number of identified geodes
    max_geodes = Dict{BluePrint, Int}()
    for blueprint in blueprints
        @show blueprint
        max_geodes[blueprint] = typemin(Int)
        state = MiningState() 
        run_simulation!(max_geodes, state, blueprint)
    end

    sum(max_geodes) do (blueprint, geodes)
        blueprint.id * geodes
    end
end

function day19_part2(inp)
end
