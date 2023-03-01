using RMLImaging
using Documenter

DocMeta.setdocmeta!(RMLImaging, :DocTestSetup, :(using RMLImaging); recursive=true)

makedocs(;
    modules=[RMLImaging],
    authors="Kazunori Akiyama",
    repo="https://github.com/EHTJulia/RMLImaging.jl/blob/{commit}{path}#{line}",
    sitename="RMLImaging.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ehtjulia.github.io/RMLImaging.jl",
        edit_link="main",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
    ]
)

deploydocs(;
    repo="github.com/EHTJulia/RMLImaging.jl",
    devbranch="main"
)
