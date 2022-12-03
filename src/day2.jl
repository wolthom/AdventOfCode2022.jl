const game_scores = (
    (3, 6, 0), # (Rock, X)
    (0, 3, 6), # (Paper, X)
    (6, 0, 3), # (Scissors, X)
)

const hand_map = (
    (3, 1, 2), # Rock
    (1, 2, 3), # Paper
    (2, 3, 1), # Scissors
)


"""
    parse_day2(inp_str)

Returns a vector of matches played.
Each match is represented as an tuple of `Hand` enums.
"""
function parse_day2(inp_str)
    matches = eachsplit(inp_str, "\n")
    map(matches) do match
        (Char(match[1]) - 'A' + 1, Char(match[3]) - 'X' + 1)
    end |> collect
end

function day2_part1(inp)
    sum(inp) do match
        game_scores[match[1]][match[2]] + match[2]
    end
end


# TODO: Implement (Char, Char) -> Game mapping according to Part 2
function day2_part2(inp)
    sum(inp) do match
        hand = hand_map[match[1]][match[2]]
        game_scores[match[1]][hand] + hand
    end
end
