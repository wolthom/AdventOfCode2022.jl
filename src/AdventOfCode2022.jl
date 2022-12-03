module AdventOfCode2022

# ~~~~~ Utility functions
include("./load.jl")
export load_day

# ~~~~~ Solutions for the days
include("./day1.jl")
export parse_day1, day1_part1, day1_part2

include("./day2.jl")
export parse_day2, day2_part1, day2_part2

end # module AdventOfCode2022
