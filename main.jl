using AdventOfCode2022
using DotEnv

cfg = DotEnv.config()

function main()
    st = ENV["session"]
    @run_days 22 st
end

main()
