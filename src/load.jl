using Downloads

const DAY_SLUG = "DAY_NUMBER"
const DOWNLOAD_URL = "https://adventofcode.com/2022/day/$DAY_SLUG/input"

function load_day(day, session_token, data_dir="./data") 
    file_name = "day_$day.txt"
    file_path = joinpath(data_dir, file_name)

    # Just return the local data if the file exists
    if isfile(file_path)
        return read(file_path)
    end
    
    # Otherwise try downloading it
    if !ispath(data_dir)
        mkdir(data_dir)
    elseif isfile(data_dir)
        throw(ArgumentError("$data_dir is a file but should be a directory to store the puzzle data in."))
    end

    # Download and store data
    download_day(day, session_token, file_path) 

    # At this point the data has to be present, so just try loading again
    return load_day(day, session_token, data_dir)
end

function download_day(day, session_token, target_path)
    url = replace(DOWNLOAD_URL, DAY_SLUG => string(day)) 
    println(url)

    Downloads.download(url, target_path, headers=Dict("Cookie" => "session=$session_token"))
end
