struct FileEntry{T}
    path::T
    size::Int64
end

function path(e::FileEntry)
    e.path
end

struct DirEntry{T}
    path::T
end

function path(d::DirEntry)
    d.path
end

const FsEntry = Union{FileEntry, DirEntry}

function parse_day7(inp_str)
    cur_path = "/"
    entries = Vector{FsEntry}()
    push!(entries, DirEntry("/"))
    for line in eachsplit(inp_str, '\n')
        # Update current path if cd is encountered
        if startswith(line, "\$ cd")
            cur_path = parse_cd(cur_path, line)
            continue
        end

        # Handle ls output
        startswith(line, "\$ ls") && continue
        push!(entries, parse_ls_line(cur_path, line))
    end
    sort!(entries; by=path)
    entries
end

function parse_cd(cur_path, line)
    new_path = ""
    if contains(line, "..")
        new_path = rsplit(cur_path, '/')[begin]
    else  
        new_path = joinpath(cur_path, split(line)[end])
    end
    new_path == "" ? "/" : new_path
end

function parse_ls_line(cur_path, line)
    p1, p2 = split(line, ' ')
    p1 == "dir" && return DirEntry(joinpath(cur_path, p2))
    FileEntry(joinpath(cur_path, p2), parse(Int64, p1))
end

function day7_part1(inp)
    dir_sizes = Vector{Tuple{DirEntry, Int64}}()
    for idx in eachindex(inp)
        e = inp[idx]
        if e isa DirEntry
            p = path(e)
            same_path = x->(startswith(path(x), p))
            sidx, eidx = (findfirst(same_path, inp), findlast(same_path, inp))
            subarr = @view inp[sidx:eidx]
            dir_size = Iterators.map(x->x.size, Iterators.filter(x->x isa FileEntry, subarr)) |> x -> sum(x; init=0)
            0 < dir_size <= 100_000 && push!(dir_sizes, (e, dir_size)) 
        else
            continue
        end
    end
    # sort!(dir_sizes; by=x->x[2])
    # dir_sizes
    sum(dir_sizes) do el
        el[2]
    end
end

function day7_part2(inp)
end
