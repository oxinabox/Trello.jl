# Trello  [![lifecycle: Maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://oxinabox.github.io/Trello.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://oxinabox.github.io/Trello.jl/dev)
[![Build Status](https://travis-ci.com/oxinabox/Trello.jl.svg?branch=master)](https://travis-ci.com/oxinabox/Trello.jl)
[![Codecov](https://codecov.io/gh/oxinabox/Trello.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/oxinabox/Trello.jl)


This is an unofficial julia client for [Trello](https://trello.com/).

It is not a direct wrapper of the [Trello REST API](https://developers.trello.com/reference/), but it is close.
It tries to be a little more convenient for typical use cases.
(For example, cards and lists are sorted as they apppear in the web-app. Archived cards are not shown).
For more direct control, use the `Trello.request` function, which will just call the API, and not do any post/preprocessing.

The API is not complete, you can find what operations we currently have in the docs.
It is very easy to add any method, as you need it.
Generally just a few lines of code, after reading the API docs.
**PRs are welcome, and easy to make.**

In general methods are prefixed with:
 - `create_[item]`: e.g. `create_card`
 - `get_[items]`: e.g. `get_lists`
 - `delete_item`: e.g. `delete_board`
It should be fairly obvious what they do. They all have docstrings.

The methods all tend to return a `NamedTuple` response,
or a ordered dictionary of items indexed by name.
Where each item is a `NamedTuple`.
This means that calling `values(get_[items](...))` will return a valid [`Tables.jl`](https://github.com/JuliaData/Tables.jl) Table.

### Demo:
Here we demo:

 - instantiating credentials (from environment variables. `TRELLO_API_KEY`, `TRELLO_API_TOKEN`)
 - creating a board
 - creating a list
 - adding some cards to that list
 - reading them back down
 - rendering them as a `DataFrame`.

```
julia> using Trello

julia> cred = TrelloCred()
TrelloCred(<secrets>)

julia> board_resp = create_board(cred, "ZZZ_Demo");

julia> list_resp = create_list(cred, board_resp.id, "Tasks")
(id = "5d72175351f2b73b0f872e03", name = "Tasks", closed = false, idBoard = "5d721712fa52696736da60c
f", pos = 16384, limits = NamedTuple())

julia> asyncmap(1:10) do task_num
       create_card(cred, list_resp.id, "Task $task_num"; desc="This is a important task")
       end;

julia> cards = get_cards(cred, list_resp.id)
OrderedCollections.LittleDict{String,Any,Array{String,1},Array{Any,1}} with 10 entries:
  "Task 1"  => (id = "5d7217c13e1a40802d3e9006", checkItemStates = nothing, closed = false, dateLas…
  "Task 2"  => (id = "5d7217c1c402bc42ee4a48dc", checkItemStates = nothing, closed = false, dateLas…
  "Task 3"  => (id = "5d7217c1f2b19a406863da02", checkItemStates = nothing, closed = false, dateLas…
  "Task 5"  => (id = "5d7217c2675c6e89ed791d40", checkItemStates = nothing, closed = false, dateLas…
  "Task 6"  => (id = "5d7217c24ee7670139e47d1b", checkItemStates = nothing, closed = false, dateLas…
  "Task 4"  => (id = "5d7217c205088042e3ebd126", checkItemStates = nothing, closed = false, dateLas…
  "Task 8"  => (id = "5d7217c2d6c9253eff228fe8", checkItemStates = nothing, closed = false, dateLas…
  "Task 7"  => (id = "5d7217c254fe39741b79371d", checkItemStates = nothing, closed = false, dateLas…
  "Task 9"  => (id = "5d7217c24f080a5833454150", checkItemStates = nothing, closed = false, dateLas…
  "Task 10" => (id = "5d7217c31b352132d291f077", checkItemStates = nothing, closed = false, dateLas…

julia> df = DataFrame(values(cards))
10×27 DataFrame. Omitted printing of 22 columns
│ Row │ id                       │ checkItemStates │ closed │ dateLastActivity         │ desc                     │
│     │ String                   │ Nothing         │ Bool   │ String                   │ String                   │
├─────┼──────────────────────────┼─────────────────┼────────┼──────────────────────────┼──────────────────────────┤
│ 1   │ 5d7217c13e1a40802d3e9006 │                 │ 0      │ 2019-09-06T08:24:33.278Z │ This is a important task │
│ 2   │ 5d7217c1c402bc42ee4a48dc │                 │ 0      │ 2019-09-06T08:24:33.574Z │ This is a important task │
│ 3   │ 5d7217c1f2b19a406863da02 │                 │ 0      │ 2019-09-06T08:24:33.826Z │ This is a important task │
│ 4   │ 5d7217c2675c6e89ed791d40 │                 │ 0      │ 2019-09-06T08:24:34.044Z │ This is a important task │
│ 5   │ 5d7217c24ee7670139e47d1b │                 │ 0      │ 2019-09-06T08:24:34.284Z │ This is a important task │
│ 6   │ 5d7217c205088042e3ebd126 │                 │ 0      │ 2019-09-06T08:24:34.463Z │ This is a important task │
│ 7   │ 5d7217c2d6c9253eff228fe8 │                 │ 0      │ 2019-09-06T08:24:34.596Z │ This is a important task │
│ 8   │ 5d7217c254fe39741b79371d │                 │ 0      │ 2019-09-06T08:24:34.773Z │ This is a important task │
│ 9   │ 5d7217c24f080a5833454150 │                 │ 0      │ 2019-09-06T08:24:34.991Z │ This is a important task │
│ 10  │ 5d7217c31b352132d291f077 │                 │ 0      │ 2019-09-06T08:24:35.103Z │ This is a important task │

julia> delete_board(cred, board_id)
(_value = nothing,)
```
