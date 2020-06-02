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
    create_board(cred::TrelloCred, name; desc="", id_organization="")

Create a new board on the `cred` account.
Board is created completely empty (no lists, nor labels).
If `id_organization` is provided then it will be created within that organization.
"""
function create_board(cred::TrelloCred, name; desc="", id_organization="")
    post_request(cred, "/1/boards/",
        name=name,
        desc=desc,
        idOrganization=id_organization,
        defaultLists=false,
        defaultLabels=false,
    )
end

"""
    delete_board(cred::TrelloCred, board_id|board)

Deletes the board.
"""
delete_board(cred::TrelloCred, board_id::AbstractString) = delete_request(cred, "/1/boards/$board_id")
delete_board(cred::TrelloCred, board) = delete_board(cred, board.id)


"""
    create_list(credit::TrelloCred, board_id|board, name, pos="bottom")

Create a list within the given board, with the given `name`,
at position given by `pos`
"""
function create_list(cred::TrelloCred, board_id::AbstractString, name, pos="bottom")
    resp = post_request(cred, "/1/boards/$(board_id)/lists"; name=name, pos=pos)
    return resp
end
create_list(cred::TrelloCred, board, args...) = create_list(cred, board.id, args...)

"""
    get_lists(cred::TrelloCred, board_id|board)

Get all the lists within a given Trello board.
"""
function get_lists(cred::TrelloCred, board_id::AbstractString)
    raw = get_request(cred, "/1/boards/$(board_id)/lists")
    return indexed_collection(sortbypos(filteroutclosed(raw)))
end
get_lists(cred::TrelloCred, board) = get_lists(cred, board.id)

"""
    get_labels(cred::TrelloCred, board_id|board)

Get all the labels within a given Trello board.
"""
function get_labels(cred::TrelloCred, board_id::AbstractString)
    raw = get_request(cred, "/1/boards/$(board_id)/labels")
    return indexed_collection(raw)
end
get_labels(cred::TrelloCred, board) = get_labels(cred, board.id)

"""
    create_card(cred::TrelloCred, list_id|list, name; desc="", label_ids::Vector=[])

Create a card, on the given list with the name, description and labels as specified.

See Trello docs:
 - https://developers.trello.com/reference#cards-2
 - https://api.trello.com/1/cards?idList=idList&keepFromSource=all
"""
function create_card(cred::TrelloCred, list_id::AbstractString, name; desc="", label_ids::Vector=[])
    return post_request(cred, "/1/cards";
        idList=list_id,
        name =name,
        desc=desc,
        idLabels = join(label_ids, ",")
    )
end
function create_card(cred::TrelloCred, list, args...; kwargs...)
    return create_card(cred, list.id, args...; kwargs...)
end

"""
    get_cards(cred::TrelloCred, list_id|list)

Returns all the cards on a given list.
"""
function get_cards(cred::TrelloCred, list_id::AbstractString)
    raw = get_request(cred, "/1/lists/$(list_id)/cards")
    cards = sortbypos(filteroutclosed(raw))
    return indexed_collection(cards)
end
get_cards(cred::TrelloCred, list) = get_cards(cred, list.id)
