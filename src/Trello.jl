module Trello
using OrderedCollections
using HTTP
using JSON2

export TrelloCred
export get_boards, get_lists, get_labels, get_cards
export create_board, create_lists, create_card

#######################################################################
# Auth

"""
    TrelloCred(;api_key, api_token)

A credentials and identity object for Trello.
If the api_key or api_token are not provided, they will be read from
the `TRELLO_API_KEY` and `TRELLO_API_TOKEN` environment variables respectively.

Follow the instructions in the [Trello Documentation](https://developers.trello.com/docs/api-introduction#section--a-name-auth-authentication-and-authorization-a-) to aquire your credentials.
"""
struct TrelloCred
    api_key::String
    api_token::String
end

function TrelloCred(;api_key=ENV["TRELLO_API_KEY"], api_token=ENV["TRELLO_API_TOKEN"])
    return TrelloCred(api_key, api_token)
end

Base.show(io::IO, ::TrelloCred) = println(io, "TrelloCred(<secrets>)")

query_parts(cred::TrelloCred) = ["key"=>cred.api_key, "token"=>cred.api_token]

function request(method, cred, path; query_kwargs...)
    query = query_parts(cred)
    for (key, value) in query_kwargs
        push!(query, string(key) => string(value))
    end
    uri = HTTP.URI(host="api.trello.com", scheme="https", path=path, query=query)
    resp = HTTP.request(method, uri)
    return JSON2.read(String(resp.body))
end

get_request(cred, path; query_kwargs...) = request("GET", cred, path; query_kwargs...)
post_request(cred, path; query_kwargs...) = request("POST", cred, path; query_kwargs...)


function indexed_collection(collection, index=:name)
    keys = getproperty.(collection, index)
    return LittleDict(keys, collection)
end
#########################################################
# Functionality

"""
    get_boards(cred::TrelloCred)

List all Trello boards on your account.
(On the account assoicated with the credentials.)
"""
function get_boards(cred::TrelloCred)
    boards = get_request(cred, "/1/members/me/boards")
    # Technically board name is not garenteed to be unique, but the edge case where it
    # is not is so rare that I'ld rather have this cleaner API.
    return indexed_collection(boards)
end

"""
    create_list(board_id, name, pos="top"; cred::TrelloCred)

Create a list within the given board, with the given `name`,
at position given by `pos`
"""
function create_list(board_id, name, pos="top"; cred::TrelloCred)
    resp = post_request(cred, "/1/boards/$(board_id)/lists"; name=name, pos=pos)
    return resp
end

"""
    get_lists(board_id; cred::TrelloCred)

Get all the lists within a given Trello board.
"""
function get_lists(board_id; cred::TrelloCred)
    raw = get_request(cred, "/1/boards/$(board_id)/lists")
    return indexed_collection(raw)
end

"""
    get_labels(board_id; cred::TrelloCred)

Get all the labels within a given Trello board.
"""
function get_labels(board_id; cred::TrelloCred)
    raw = get_request(cred, "/1/boards/$(board_id)/labels")
    return indexed_collection(raw)
end

"""
    create_card(list_id, name, description=""; label_ids::Vector=[], cred::TrelloCred)

Create a card, on the given list with the name, description and labels as specified.

See Trello docs:
 - https://developers.trello.com/reference#cards-2
 - https://api.trello.com/1/cards?idList=idList&keepFromSource=all
"""
function create_card(list_id, name, desc=""; label_ids::Vector=[], cred::TrelloCred)
    return post_request(cred, "/1/cards";
        idList=list_id,
        name =name,
        desc=desc,
        idLabels = join(label_ids, ",")
    )
end

"""
    get_cards(list_id; cred::TrelloCred)

return a all the cards on a given board.
"""
function get_cards(list_id; cred::TrelloCred)
    raw = get_request(cred, "/1/lists/$(list_id)/cards")
    cards = sort(
        [card for card in raw if !card.closed];
        by=card->card.pos
    )
    return indexed_collection(cards)
end

end #module
