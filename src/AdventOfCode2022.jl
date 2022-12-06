module AdventOfCode2022

# ~~~~~ Utility functions
include("./load.jl")
export load_day

# ~~~~~ Solutions for the days
include("./day1.jl")
export parse_day1, day1_part1, day1_part2

include("./day2.jl")
export parse_day2, day2_part1, day2_part2

include("./day3.jl")
export parse_day3, day3_part1, day3_part2

include("./day4.jl")
export parse_day4, day4_part1, day4_part2

end # module AdventOfCode2022
