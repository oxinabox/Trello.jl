
query_parts(cred::TrelloCred) = ["key"=>cred.api_key, "token"=>cred.api_token]

function request(method, cred, path; query_kwargs...)
    query = query_parts(cred)
    for (key, value) in query_kwargs
        isempty(value) && continue
        push!(query, string(key) => string(value))
    end
    uri = HTTP.URI(host="api.trello.com", scheme="https", path=path, query=query)
    resp = HTTP.request(method, uri)
    return JSON2.read(String(resp.body))
end

get_request(cred, path; query_kwargs...) = request("GET", cred, path; query_kwargs...)
post_request(cred, path; query_kwargs...) = request("POST", cred, path; query_kwargs...)
put_request(cred, path; query_kwargs...) = request("PUT", cred, path; query_kwargs...)
delete_request(cred, path; query_kwargs...) = request("DELETE", cred, path; query_kwargs...)


function indexed_collection(collection, index=:name)
    keys = getproperty.(collection, index)
    return LittleDict(keys, collection)
end
