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

function day15_part1(sensors)
    y = 2_000_000
    # Extract unique beacons and covered positions
    beacons = Set{CartesianIndex{2}}()
    positions = Set{Int}()
    f = Base.Fix1(push!, positions)
    foreach(sensors) do sensor
        push!(beacons, sensor.beacon_pos)
        covered = covered_range(sensor, y)
        foreach(f, covered)
    end
    beacons
end

function day15_part2(inp)
end
