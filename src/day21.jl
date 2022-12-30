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

function contains_node(tree, parent_node, target_node)
    parent_node.name == target_node.name && return true
    parent_node isa IntNode && return false
    left_child = get_node(tree, parent_node.left_child)
    right_child = get_node(tree, parent_node.right_child)
    return (
            (parent_node.left_child == target_node.name) ||
            (parent_node.right_child == target_node.name) ||
            (left_child isa OpNode && contains_node(tree, left_child, target_node)) ||
            (right_child isa OpNode && contains_node(tree, right_child, target_node))
    )
end

function reverse_ops(cache, tree, node, target_node, val)
    node.name == "humn" && return val

    subtree = ""

    # Keep traversing the subtree that contains the "humn" node
    while !(node isa IntNode)
        right_node = get_node(tree, node.right_child)
        left_node = get_node(tree, node.left_child)
        right_val = calculate_cached!(cache, tree, right_node)
        left_val = calculate_cached!(cache, tree, left_node)

        (node, val) = if contains_node(tree, left_node, target_node)
            # val = left 'op' right ==> left = val 'inv-op' right
            new_val = node.op == '-' ? val + right_val :
                        node.op == '+' ? val - right_val :
                        node.op == '*' ? div(val, right_val) : val * right_val
            (left_node, new_val)
        else
            # val = left 'op' right ==> right = left 'op' right
            new_val = node.op == '-' ? left_val - val :
                        node.op == '+' ? val - left_val :
                        node.op == '*' ? div(val, left_val) : div(left_val, val)
            (right_node, new_val)
        end
    end
    node, val
end


function day21_part2(tree)
    tree = deepcopy(tree)
    # Grab relevant nodes
    root = get_node(tree, "root")
    left = get_node(tree, root.left_child)
    right = get_node(tree, root.right_child)
    humn = get_node(tree, "humn")

    # Calculate current result
    cache = Dict{String7, Int}()
    root_val = calculate_cached!(cache, tree, root) 

    # Identify 
    left_val = calculate_cached!(cache, tree, left)
    right_val = calculate_cached!(cache, tree, right)

    (target_val, start_node) = if contains_node(tree, left, humn)
        (right_val, left)
    elseif contains_node(tree, right, humn)
        (left_val, right)
    else 
        throw(DomainError("Neither left nor right subtree contain 'humn' node"))
    end

    reverse_ops(cache, tree, start_node, humn, target_val)[2]
end

