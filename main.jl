using AdventOfCode2022
using DotEnv

cfg = DotEnv.config()

function main()
    st = ENV["session"]
    @run_days 17 st
end

main()

