using EnumX
using MLStyle

@data Hand begin
    Rock
    Paper
    Scissors
end

"""
    parse_day2(inp_str)

Returns a vector of matches played.
Each match is represented as an tuple of `Hand` enums.
"""
function parse_day2(inp_str)
    matches = eachsplit(inp_str, "\n")
    map(matches) do match
        (Char(match[1]), Char(match[3]))
    end |> collect
end

function to_hand(num)
    @match num begin
        0 => Rock
        1 => Paper
        2 => Scissors
    end
end

function day2_part1(inp)
    games = map(inp) do match
        (to_hand(match[1] - 'A'), to_hand(match[2] - 'X'))
    end
    sum(game_score, games) 
end


# TODO: Implement (Char, Char) -> Game mapping according to Part 2
function day2_part2(inp)
end

function game_score(game)
    hand_score(game[2]) + @match game begin
        (Rock, Paper) => 6
        (Paper, Scissors) => 6
        (Scissors, Rock) => 6
        (h1, h2) => h1 == h2 ? 3 : 0
    end
end

function hand_score(h)
    @match h begin
        Rock => 1
        Paper => 2
        Scissors => 3
    end
end
