using DiscreteRandomMediaGen
using Documenter

DocMeta.setdocmeta!(DiscreteRandomMediaGen,
                    :DocTestSetup,
                    :(using DiscreteRandomMediaGen);
                    recursive = true)

makedocs(;
         modules = [DiscreteRandomMediaGen],
         authors = "Gabriel Wu <wuzihua@pku.edu.cn> and contributors",
         repo = "https://github.com/JuliaRemoteSensing/DiscreteRandomMediaGen.jl/blob/{commit}{path}#{line}",
         sitename = "DiscreteRandomMediaGen.jl",
         format = Documenter.HTML(;
                                  prettyurls = get(ENV, "CI", "false") == "true",
                                  canonical = "https://JuliaRemoteSensing.github.io/DiscreteRandomMediaGen.jl",
                                  edit_link = "main",
                                  assets = String[]),
         pages = ["Home" => "index.md",
             "References" => "ref.md"])

deploydocs(;
           repo = "github.com/JuliaRemoteSensing/DiscreteRandomMediaGen.jl",
           devbranch = "main")
