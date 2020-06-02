using Trello
using Test
using UUIDs

@testset "Trello.jl" begin

    cred = TrelloCred()
    @testset "End to End Usage" begin
        new_board_name = "ZZ_testing_$(uuid1())"

        # Should be able to create boards:
        new_board = create_board(cred, new_board_name; desc="testing")
        boards = get_boards(cred)
        @test haskey(boards, new_board_name)
        board = boards[new_board_name]
        @test board.desc == "testing"
        board_id = boards[new_board_name].id

        # the resturn from `create_board` at least has same key fields as can be read from `get_boards`
        @test new_board.id == board.id
        @test new_board.name == board.name

        # Test labels
        @test isempty(get_labels(cred, board_id))
        @test isempty(get_labels(cred, board))  # not passing ID but passing the board object

        # Should be able to create lists
        create_list(cred, board_id, "L1")
        create_list(cred, board_id, "L2")
        create_list(cred, board, "L3")  # not passing ID but passing the board object

        # should be able to get all the lists
        lists = get_lists(cred, board_id)
        @test lists == get_lists(cred, board)  # not passing ID but passing the board object

        @test collect(keys(lists)) == ["L1", "L2", "L3"]
        list = lists["L2"]
        list_id = list.id

        # Test cards
        create_card(cred, list_id, "C1")
        create_card(cred, list_id, "C2")
        create_card(cred, list, "C3")  # not passing ID but passing the list object

        cards = get_cards(cred, list_id)
        @test get_cards(cred, list) == cards   # same result wether using list_id or list object
        @test collect(keys(cards)) == ["C1", "C2", "C3"]


        # After deleting board should be gone
        delete_board(cred, board_id)
        @test !haskey(get_boards(cred), new_board_name)
    end

    @testset "delete_board by board object" begin
        new_board_name = "YY_testing_$(uuid1())"
        # Should be able to create boards:
        board = create_board(cred, new_board_name)
        @test haskey(get_boards(cred), new_board_name)
        delete_board(cred, board)
        @test !haskey(get_boards(cred), new_board_name)
    end
end
