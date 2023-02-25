export radial_distribution

function radial_distribution(xml; binwidth = 0.01, length::Union{Nothing, Int} = nothing)
    rdis = nothing

    mktempdir() do tmpdir
        try
            config_xml = joinpath(tmpdir, "config.xml")
            output_xml = joinpath(tmpdir, "output.xml")
            stats_xml = joinpath(tmpdir, "stats.xml")
            write(config_xml, xml)
            if isnothing(length)
                run(`$(dynarun()) $config_xml -c0 -LRadialDistribution:BinWidth=$binwidth -o$output_xml --out-data-file $stats_xml`)
            else
                run(`$(dynarun()) $config_xml -c0 -LRadialDistribution:BinWidth=$binwidth,Length=$length -o$output_xml --out-data-file $stats_xml`)
            end
            xml = readxml(stats_xml)
            data = map(filter(x -> !isempty(strip(x)),
                              split(findfirst("//Species", xml).content, "\n"))) do line
                parse.(Float64, split(line))
            end
            r = map(x -> x[1], data)
            g = map(x -> x[2], data)
            rdis = r, g
        catch e
            @error "error occured while calculating radial distribution" exception=e
        end
    end

    return rdis
end
