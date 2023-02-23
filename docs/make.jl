using DiscreteRandomMediaGen
using Documenter

DocMeta.setdocmeta!(DiscreteRandomMediaGen, :DocTestSetup, :(using DiscreteRandomMediaGen); recursive=true)

makedocs(;
    modules=[DiscreteRandomMediaGen],
    authors="Gabriel Wu <wuzihua@pku.edu.cn> and contributors",
    repo="https://github.com/lucifer1004/DiscreteRandomMediaGen.jl/blob/{commit}{path}#{line}",
    sitename="DiscreteRandomMediaGen.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://lucifer1004.github.io/DiscreteRandomMediaGen.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/lucifer1004/DiscreteRandomMediaGen.jl",
    devbranch="main",
)
