module AdventOfCode2022

# ~~~~~ Utility functions
include("./load.jl")
export load_day

include("./run.jl")
export @run_days

# ~~~~~ Solutions for the days
include("./day1.jl")
export parse_day1, day1_part1, day1_part2

include("./day2.jl")
export parse_day2, day2_part1, day2_part2

include("./day3.jl")
export parse_day3, day3_part1, day3_part2

include("./day4.jl")
export parse_day4, day4_part1, day4_part2

include("./day5.jl")
export parse_day5, day5_part1, day5_part2

include("./day6.jl")
export parse_day6, day6_part1, day6_part2

include("./day7.jl")
export parse_day7, day7_part1, day7_part2

include("./day8.jl")
export parse_day8, day8_part1, day8_part2

include("./day9.jl")
export parse_day9, day9_part1, day9_part2

end # module AdventOfCode2022
