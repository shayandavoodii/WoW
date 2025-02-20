using HTTP, JSON3

remote_repo_url = "https://raw.githubusercontent.com/NiREvil/vless/refs/heads/main/sing-box.json"
output_file_path = "modified_file.json"

response = HTTP.get(remote_repo_url)
json_string = String(response.body)
json_data_json3 = JSON3.read(json_string)

# Convert JSON3.Object to a standard Julia Dict
json_data = convert_json3_to_dict(json_data_json3)

# Use string keys to access and modify the dictionary
json_data["dns"]["strategy"] = "prefer_ipv6"
json_data["outbounds"][3]["domain_strategy"] = "prefer_ipv6"
json_data["route"]["rules"][3]["strategy"] = "prefer_ipv6"

# Use JSON3.pretty to format the JSON for readability
open(output_file_path, "w") do io
    JSON3.pretty(io, json_data)
end

function convert_json3_to_dict(json3_data)
    if json3_data isa JSON3.Object
        dict_data = Dict{String, Any}()
        for (key, value) in json3_data
            dict_data[string(key)] = convert_json3_to_dict(value)
        end
        return dict_data
    elseif json3_data isa JSON3.Array
        array_data = []
        for item in json3_data
            push!(array_data, convert_json3_to_dict(item))
        end
        return array_data
    else
        return json3_data
    end
end
