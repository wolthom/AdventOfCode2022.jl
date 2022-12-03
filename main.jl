include("src/AdventOfCode2022.jl")
using AdventOfCode2022
using DotEnv

cfg = DotEnv.config()

inp_str = load_day(1, cfg["session"], "./data")
inp = parse_day1(inp_str)
@show day1_part1(inp)
@show day1_part2(inp)

inp_str = load_day(2, cfg["session"], "./data")

