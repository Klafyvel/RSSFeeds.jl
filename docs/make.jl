using RSS
using Documenter

DocMeta.setdocmeta!(RSS, :DocTestSetup, :(using RSS); recursive=true)

makedocs(;
    modules=[RSS],
    authors="Hugo Levy-Falk <hugo@klafyvel.me> and contributors",
    sitename="RSS.jl",
    format=Documenter.HTML(;
        canonical="https://klafyvel.github.io/RSS.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/klafyvel/RSS.jl",
    devbranch="main",
)
