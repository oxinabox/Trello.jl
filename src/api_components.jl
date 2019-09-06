"""
    request(method, cred, path; query_kwargs...)

Send a request to Trello and get back the reponse.
 - `method` is the HTTP method to use, e.g `"GET"`, `"POST"`, `"PUT"` or `"DELETE"`
    the `get_request`, `post_request`, `put_request` and `delete_request` are convenience wrapppers of `request` with the relevant method.
 - `cred`: a `TrelloCred` object for the account making the request.
 - `path` the endpoint being targetted, e.g. `"/1/boards/5d721712fa52696736da60cf/lists"`.
    Often you will need to interpolate a board or list id or similar into this. (like `5d721712fa52696736da60cf`)
 - `query_kwargs`: the query to be used with the request,
    e.g `idList="5d72175351f2b73b0f872e03", name="My new Card", desc="The card description", ...`

When invoking `request` it is important to look at the Trello API docs to workout
what arguements are allowed, and how they are spelled etc.
https://developers.trello.com/reference

Returns the parsed response.
Generally as a `NamedTuple`, or a `Vector` of `NamedTuples`

Throws errors if there are HTTP errors.
"""
function request(method, cred, path; query_kwargs...)
    query = ["key"=>cred.api_key, "token"=>cred.api_token]
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

sortbypos(collection) = sort(collection; by=x->x.pos)
filteroutclosed(collection) = filter(x->!x.closed, collection)
