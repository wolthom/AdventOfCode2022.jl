cd(@__DIR__) # go into `docs` folder

using Pkg
Pkg.activate(".")

using Documenter, Literate, AdventOfCode2022

# convert tutorial/examples to markdown
Literate.markdown("./src/tutorial.jl", "./src")

# Which markdown files to compile to HTML
# (which is also the sidebar and the table
# of contents for your documentation)
pages = [
    "Introduction" => "index.md",
    "Tutorial" => "tutorial.md",
    "API" => "api.md",
]

# compile to HTML:
makedocs(sitename="AoC2022"; pages, modules=[AdventOfCode2022], remotes=nothing, warnonly=true)

deploydocs(
    repo="github.com/wolthom/AdventOfCode2022.jl.git",
)