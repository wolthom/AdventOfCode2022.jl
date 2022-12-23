struct Sensor
    sensor_pos::CartesianIndex{2}
    beacon_pos::CartesianIndex{2}
end

const line_regex = r".*? x=(-?\d*), y=(-?\d*).*? x=(-?\d*), y=(-?\d*)"

function parse_day15(inp_str)
    map(eachsplit(chomp(inp_str), '\n')) do line
        ys, xs, yb, xb = (parse(Int, el) for el in match(line_regex, line))
        Sensor(CartesianIndex(xs, ys), CartesianIndex(xb, yb))
    end |> collect
end

function covered_range(sensor, y_coord)
    # Calculate covered area
    delta = sensor.sensor_pos - sensor.beacon_pos
    max_dist = abs(delta[1]) + abs(delta[2])
    y_dist = abs(sensor.sensor_pos[1]-y_coord)
    # If queried y-row is outside of area, return empty range
    y_dist > max_dist && return 1:-1

    # Otherwise the covered range is the sensor y-position +/- offset/2 
    offset = (max_dist - y_dist)
    (sensor.sensor_pos[2]-offset):(sensor.sensor_pos[2]+offset)
end

function range_comp(r1, r2)
    r1[begin] < r2[begin] && return true
    r1[begin] > r2[begin] && return false
    r1[end] < r2[end] && return true
    r1[end] > r2[end] && return false
end

function overlaps(r1, r2)
    # Overlapping regions or touching endpoints
    !isempty(intersect(r1, r2)) || r1[end] == r2[begin]
end

function fuse_ranges!(ranges)
    # Remove empty ranges and sort valid ones
    filter!(!isempty, ranges)

    # TODO: Figure out why sort! with the standard lt is extremely inefficient
    #       Also: This does not appear to be the case when benchmarked by itself but only in a larger context
    sort!(ranges; lt=range_comp) 

    # Iteratively fuse overlapping ranges
    ctr = 1
    idx = 1
    while idx < length(ranges)
        ctr += 1
        # Proceed to next element if current and next element do not overlap
        !overlaps(ranges[idx], ranges[idx+1]) && (idx += 1; continue)

        # Otherwise expand current element by next one and remove subsumed next element
        new_range = ranges[idx][begin]:max(ranges[idx][end], ranges[idx+1][end])
        ranges[idx] = new_range
        deleteat!(ranges, idx+1)
    end
    ranges
end

function day15_part1(sensors)
    y = 2_000_000
    # y = 10

    # Extract unique beacons and calculate covered positions
    beacons = Set{CartesianIndex{2}}()
    ranges = UnitRange{Int64}[]
    foreach(sensors) do sensor
        push!(beacons, sensor.beacon_pos)
        push!(ranges, covered_range(sensor, y))
    end

    # Fuse overlapping ranges
    fuse_ranges!(ranges)
    
    max_covered = sum(Iterators.map(length, ranges))
    beacons_in_line = sum(any(r -> b[1] == y && b[2] ∈ r, ranges) for b in beacons)
    max_covered - beacons_in_line
end

# TODO: Optimize part 2
#         Idea 1: Use IntervalArithmetic.jl to continuously remove covered areas from the search space
#                 This would require rotating the coordinate space by 45°, widening the search space and then shrinking it again
#         Idea 2: Walk the immediate neighborhood of each rectangle until a point is found that is not part of any rectangles
function day15_part2(sensors)
    x_range = 0:4_000_000
    y_range = 0:4_000_000
    ranges = UnitRange{Int64}[]
    for y in y_range
        empty!(ranges)
        # Extract unique beacons and calculate covered positions
        foreach(sensors) do sensor
            push!(ranges, covered_range(sensor, y))
        end

        # Fuse overlapping ranges
        fuse_ranges!(ranges)

        # Entire x-area is covered by sensors
        length(ranges) == 1 && x_range ⊆ only(ranges) && continue
        
        # Identify not covered x position
        x_pos = if length(ranges) == 1 && only(ranges)[begin] > x_range[begin]
            x_range[begin]
        elseif length(ranges) == 1 && only(ranges)[end] < x_range[end]
            x_range[end]
        else
            # Overlap must be after first covered segment due to sorting
            ranges[1][end]+1
        end
        return x_pos * 4_000_000 + y
    end
end
