struct LineSegment
    sidx::CartesianIndex{2}
    eidx::CartesianIndex{2}
end

Base.min(l::LineSegment) = min(l.sidx, l.eidx)
Base.max(l::LineSegment) = max(l.sidx, l.eidx)

struct Line
    segments::Vector{LineSegment}
end

Base.minimum(l::Line) = reduce(min, l.segments)
Base.maximum(l::Line) = reduce(min, l.segments)

function parse_day14(inp_str)
end

function day14_part1(inp)
end

function day14_part2(inp)
end
