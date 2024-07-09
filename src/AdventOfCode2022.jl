"""
Example doc string
"""
module AdventOfCode2022
using Reexport

# ~~~~~ Utility functions
include("./load.jl")
export load_day

include("./run.jl")
export @run_days

# ~~~~~ Solutions for the days
module Day1
include("./day1.jl")
export parse_day1, day1_part1, day1_part2
end # module Day1
@reexport using .Day1

module Day2
include("./day2.jl")
export parse_day2, day2_part1, day2_part2
end # module Day2
@reexport using .Day2

module Day3
include("./day3.jl")
export parse_day3, day3_part1, day3_part2
end # module Day3
@reexport using .Day3

module Day4
include("./day4.jl")
export parse_day4, day4_part1, day4_part2
end # module Day4
@reexport using .Day4

module Day5
include("./day5.jl")
export parse_day5, day5_part1, day5_part2
end # module Day5
@reexport using .Day5

module Day6
include("./day6.jl")
export parse_day6, day6_part1, day6_part2
end # module Day6
@reexport using .Day6

module Day7
include("./day7.jl")
export parse_day7, day7_part1, day7_part2
end # module Day7
@reexport using .Day7

module Day8
include("./day8.jl")
export parse_day8, day8_part1, day8_part2
end # module Day8
@reexport using .Day8

module Day9
include("./day9.jl")
export parse_day9, day9_part1, day9_part2
end # module Day9
@reexport using .Day9

module Day10
include("./day10.jl")
export parse_day10, day10_part1, day10_part2
end # module Day10
@reexport using .Day10

module Day11
include("./day11.jl")
export parse_day11, day11_part1, day11_part2
end # module Day11
@reexport using .Day11

module Day12
include("./day12.jl")
export parse_day12, day12_part1, day12_part2
end # module Day12
@reexport using .Day12

module Day13
include("./day13.jl")
export parse_day13, day13_part1, day13_part2
end # module Day13
@reexport using .Day13

module Day14
include("./day14.jl")
export parse_day14, day14_part1, day14_part2
end # module Day14
@reexport using .Day14

module Day15
include("./day15.jl")
export parse_day15, day15_part1, day15_part2
end # module Day15
@reexport using .Day15

module Day16
include("./day16.jl")
export parse_day16, day16_part1, day16_part2
end # module Day16
@reexport using .Day16

module Day17
include("./day17.jl")
export parse_day17, day17_part1, day17_part2
end # module Day17
@reexport using .Day17

module Day18
include("./day18.jl")
export parse_day18, day18_part1, day18_part2
end # module Day18
@reexport using .Day18

module Day19
include("./day19.jl")
export parse_day19, day19_part1, day19_part2
end # module Day19
@reexport using .Day19

module Day20
include("./day20.jl")
export parse_day20, day20_part1, day20_part2
end # module Day20
@reexport using .Day20

module Day21
include("./day21.jl")
export parse_day21, day21_part1, day21_part2
end # module Day21
@reexport using .Day21

module Day22
include("./day22.jl")
export parse_day22, day22_part1, day22_part2
end # module Day22
@reexport using .Day22

module Day23
include("./day23.jl")
export parse_day23, day23_part1, day23_part2
end # module Day23
@reexport using .Day23

module Day24
include("./day24.jl")
export parse_day24, day24_part1, day24_part2
end # module Day24
@reexport using .Day24

end # module AdventOfCode2022
