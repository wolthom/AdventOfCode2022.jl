using IterTools

function name end

struct Dir{T}
    name::Union{String, SubString{String}}
    children::Vector{T}
end

function name(d::Dir)
    d.name
end

function entry_size(d::Dir)
    sum(entry_size, d.children)
end

function entry_size(d::Dir, cache::AbstractDict)
    dir_size = 0
    for child in d.children
        # Handle File-children
        if child isa File 
            dir_size += entry_size(child)
            continue
        end

        # Handle Dir-children
        child_name = name(child)
        if haskey(cache, child_name)
            dir_size += cache[child_name]
            continue
        end
        child_size = entry_size(child, cache)
        cache[child_name] = child_size

        dir_size += child_size
    end
    dir_size
end


function make_root()
    Dir("/", Vector{FsEntry}())
end

function find_dir(children, dir_name)
    idx = findfirst(children) do entry
        name(entry) |> endswith(dir_name)
    end
    isnothing(idx) && throw(InvalidStateException("cd into non-existing child directory", :Dir))
    children[idx]
end


struct File
    name::Union{String, SubString{String}}
    size::Int64
end

const FsEntry = Union{Dir, File}

function name(f::File)
    f.name
end

function entry_size(f::File)
    f.size
end

function parse_day7(inp_str)
    root = make_root()

    dir_stack = Vector{Dir}()
    push!(dir_stack, root)

    for line in eachsplit(inp_str, '\n')
        cur_dir = dir_stack[end]

        # '$ cd ..' => Move to parent
        if line == "\$ cd .."
            pop!(dir_stack)
            continue
        end

        # '$ cd DIR' => Move to subdirectory
        if startswith(line, "\$ cd")
            dir_name = split(line, ' '; limit=3)[end]
            dir_name == name(cur_dir) && continue

            push!(dir_stack, find_dir(cur_dir.children, dir_name))
            continue
        end

        # '$ ls' => Skip ls-command
        startswith(line, "\$ ls") && continue

        # Parse ls output
        if startswith(line, "dir")
            dir_name = joinpath(name(cur_dir), split(line, ' '; limit=2)[end])
            push!(cur_dir.children, Dir(dir_name, Vector{FsEntry}()))
        else
            size, file_name = split(line, " "; limit=2)
            push!(cur_dir.children, File(joinpath(name(cur_dir), file_name), parse(Int64, size)))
        end
    end
    return root
end

function day7_part1(inp)
    cache = Dict{String, Int64}()
    root_size = entry_size(inp, cache)
    
    Iterators.filter(values(cache)) do v
        v <= 100_000
    end |> sum
end

function day7_part2(inp)
    total_space = 70_000_000
    required_space = 30_000_000

    # Calculate current space
    cache = Dict{String, Int64}()
    root_size = entry_size(inp, cache)

    # Calculate how much space needs to be filled up
    free_space = total_space - root_size
    missing_space = required_space - free_space
    
    candidates = Iterators.filter(values(cache)) do v
        v >= missing_space
    end |> collect

    # Sort ascending
    sort!(candidates)

    # Grab smallest value
    candidates[begin]
end
