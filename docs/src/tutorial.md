```@meta
EditURL = "tutorial.jl"
```

# [AdventOfCode2022.jl Tutorial](@id tutorial)

`AdventOfCode2022` is a package that contains solutions and helper functions for the 2022 Advent of Code edition in Julia.
This tutorial will walk you through its main functionality and how to use the helpers.
Note: This Tutorial assumes that you have a session token from the Advent of Code website.

## Tutorial - copy-pasteable version

```julia
using AdventOfCode2022
st = ENV["session"]
@run_days 22 st
```

## Using the package

````@example tutorial
using AdventOfCode2022
````

## Example of retrieving the session key

````@example tutorial
st = ENV["session"]
````

## Actually running the solutions

````@example tutorial
@run_days 22 st
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

