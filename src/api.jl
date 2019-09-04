
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

