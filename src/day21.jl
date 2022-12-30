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
    nodes = Node[]
    for line in eachsplit(chomp(inp_str), '\n')
        push!(nodes, parse_line(line))
    end
    Tree(nodes)
end

function get_node(tree::Tree, node_name)
    pred(node) = node.name == node_name
    # TODO: Performance could be significantly improved using ordered node vector
    idx = findfirst(pred, tree.nodes)
    @assert !isnothing(idx)
    node = tree.nodes[idx]
    node 
end

function calculate_cached!(cache, tree, node)
    if haskey(cache, node.name)
        return cache[node.name]
    end

    if node isa IntNode
        return node.val
    end

    left_val = calculate_cached!(cache, tree, get_node(tree, node.left_child))
    right_val = calculate_cached!(cache, tree, get_node(tree, node.right_child))
    
    node.op == '-' ? left_val - right_val :
        node.op == '+' ? left_val + right_val :
        node.op == '*' ? left_val * right_val : div(left_val, right_val)
end

function day21_part1(tree)
    tree = deepcopy(tree)
    cache = Dict{String7, Int}()
    root = get_node(tree, "root")
    calculate_cached!(cache, tree, root) 
end

function contains_node(tree, parent_node, goal_node)
    parent_node isa IntNode && return false
    return (
            (parent_node.left_child == goal_node.name) ||
            (parent_node.right_child == goal_node.name) ||
            (contains_node(tree, get_node(tree, parent_node.left_child), goal_node)) ||
            (contains_node(tree, get_node(tree, parent_node.right_child), goal_node))
    )
end

function day21_part2(tree)
    tree = deepcopy(tree)
    # Grab relevant nodes
    root = get_node(tree, "root")
    left = get_node(tree, root.left_child.name)
    right = get_node(tree, root.right_child.name)

end
