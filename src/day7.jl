struct FileEntry{T}
    path::T
    size::Int64
end

struct DirEntry{T}
    path::T
end

function path(e::FileEntry)
    e.path
end

function path(d::DirEntry)
    d.path
end

const FsEntry = Union{FileEntry, DirEntry}

function parse_day7(inp_str)
    cur_path = ""
    entries = Vector{FsEntry}()
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
    new_path
end

function parse_ls_line(cur_path, line)
    p1, p2 = split(line, ' ')
    p1 == "dir" && return DirEntry(joinpath(cur_path, p2))
    FileEntry(joinpath(cur_path, p2), parse(Int64, p1))
end

function day7_part1(inp)
end

function day7_part2(inp)
end
