using Trello
using Test
using UUIDs

@testset "Trello.jl" begin

    cred = TrelloCred()

    original_boards = get_boards(cred)
    new_board_name = "ZZ_testing_$(uuid1())"
    
    # Should be able to create boards:
    create_board(cred::TrelloCred, new_board_name; desc="testing")
    boards = get_boards(cred)
    @test Set(keys(boards)) == Set([new_board_name, keys(original_boards)...])
    @test boards[new_board_name].desc == "testing"
    board_id = boards[new_board_name].id


    # Test labels
    @test isempty(get_labels(cred, board_id))

    # Should be able to create lists
    create_list(cred, board_id, "L1")
    create_list(cred, board_id, "L2")
    create_list(cred, board_id, "L3")

    lists = get_lists(cred, board_id)
    @test collect(keys(lists)) == ["L1", "L2", "L3"]
    list_id = lists["L2"].id

    # Test cards
    create_card(cred, list_id, "C1")
    create_card(cred, list_id, "C2")
    create_card(cred, list_id, "C3")

    cards = get_cards(cred, list_id)
    @test collect(keys(cards)) == ["C1", "C2", "C3"]


    # After deleting board should be gone
    delete_board(cred, board_id)
    @test !haskey(get_boards(cred), new_board_name)
end
