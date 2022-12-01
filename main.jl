using DotEnv
using AdventOfCode2022

cfg = DotEnv.config()

data = load_day(1, cfg["session"], "./data")

