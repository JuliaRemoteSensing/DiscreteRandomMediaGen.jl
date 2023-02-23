export radial_distribution

function radial_distribution(xml; binwidth=0.01, length::Union{Nothing, Int}=nothing)
    mktempdir() do tmpdir
        current_dir = pwd()
        rdis = nothing

        try
            cd(tmpdir)
            write("config.xml", xml)
            if isnothing(length)
                run(`$(dynarun()) config.xml -c0 -L RadialDistribution:BinWidth=$binwidth -o output.xml`)
            else
                run(`$(dynarun()) config.xml -c0 -L RadialDistribution:BinWidth=$binwidth,Length=$length -o output.xml`)
            end
            xml = readxml("output.xml")
            data = map(filter(x -> !isempty(strip(x)), split(findfirst("//Species", xml).content, "\n"))) do line
                parse.(Float64, split(line))
            end
            r = map(x -> x[1], data)
            g = map(x -> x[2], data)
            rdis = r, g
        catch e
            @error "error occured while calculating radial distribution" exception=e
        finally
            cd(current_dir)
        end

        return rdis
    end
end
