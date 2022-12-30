# TODO: Adapt structure to wrap each day in a separate submodule
using InlineStrings

# Assumption: Tree-structure
struct OpNode
    name::String7
    op::Char
    left_child::String7
    right_child::String7
end

struct IntNode
    name::String7
    val::Int
end

const Node = Union{IntNode, OpNode}

struct Tree
    root::String7
    nodes::Vector{Node}
end

function Tree(nodes::Vector{Node})
    sort!(nodes; by=Base.Fix2(getproperty, :name))
    Tree(String7("root"), nodes)
end

const INT_NODE_REGEX = r"^(\w+): (\d+)$"
const OP_NODE_REGEX = r"^(\w+): (\w+) ([+\-/*]) (\w+)"

function parse_line(line)
    m = match(INT_NODE_REGEX, line)
    !isnothing(m) && return IntNode(String7(m[1]), parse(Int, m[2]))

    m = match(OP_NODE_REGEX, line)
    @assert !isnothing(m)
    return OpNode(String7(m[1]), only(m[3]), String7(m[2]), String7(m[4]))
end

function parse_day21(inp_str)
    nodes = map(parse_line, eachsplit(chomp(inp_str), '\n'))
    Tree(nodes)
end

function day21_part1(inp)
end

function day21_part2(inp)
end
