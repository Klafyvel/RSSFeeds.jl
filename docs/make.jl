using RSSFeeds
using Documenter

DocMeta.setdocmeta!(RSSFeeds, :DocTestSetup, :(using RSSFeeds); recursive=true)

makedocs(;
    modules=[RSSFeeds],
    authors="Hugo Levy-Falk <hugo@klafyvel.me> and contributors",
    sitename="RSSFeeds.jl",
    format=Documenter.HTML(;
        canonical="https://klafyvel.github.io/RSSFeeds.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/klafyvel/RSSFeeds.jl",
    devbranch="main",
)
