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

function fuse_ranges!(ranges)
    # Remove empty ranges and sort valid ones
    filter!(!isempty, ranges)
    sort!(ranges; lt=range_comp)

    # Iteratively fuse overlapping ranges
    ctr = 1
    idx = 1
    while idx < length(ranges)
        ctr += 1
        # Proceed to next element if current and next element do not overlap
        isempty(intersect(ranges[idx], ranges[idx+1])) && (idx += 1; continue)

        # Otherwise expand current element by next one and remove subsumed next element
        new_range = ranges[idx][begin]:ranges[idx+1][end]
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

function day15_part2(inp)
end
