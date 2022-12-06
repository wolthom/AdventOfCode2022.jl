macro run_days(days)
    range = Meta.parse(days)
    out = quote end

    for day in range
        push!(out.args, run_day_expr(day))
    end

    return out
end

function run_day_expr(day)
    quote
        inp_str = load_day($day)     
        @show inp_str
    end
end
