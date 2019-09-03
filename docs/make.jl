using Documenter, Trello

makedocs(;
    modules=[Trello],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/oxinabox/Trello.jl/blob/{commit}{path}#L{line}",
    sitename="Trello.jl",
    authors="Lyndon White",
    assets=String[],
)

deploydocs(;
    repo="github.com/oxinabox/Trello.jl",
)
