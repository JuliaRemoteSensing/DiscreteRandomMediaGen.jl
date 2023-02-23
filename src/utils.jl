export readxml, parse_particles, parse_simulation_size

function readxml(filename::AbstractString)
    if endswith(filename, ".bz2")
        EzXML.parsexml(join(eachline(Bzip2DecompressorStream(open(filename))), "\n"))
    else
        EzXML.readxml(filename)
    end
end

@testitem "readxml" begin
    bz2file = joinpath(@__DIR__, "..", "fixtures", "raw.xml.bz2")
    xmlfile = joinpath(@__DIR__, "..", "fixtures", "raw.xml")
    xml_from_bz2 = readxml(bz2file)
    xml = readxml(xmlfile)

    @test string(xml_from_bz2) == string(xml)
end

function parse_particles(xml)
    map(findall("//Pt", xml)) do particle
        pos = findfirst("./P", particle)
        parse(Float64, pos["x"]), parse(Float64, pos["y"]), parse(Float64, pos["z"]), parse(Float64, particle["D"]) / 2
    end
end

@testitem "parse_particles" begin
    xml = readxml(joinpath(@__DIR__, "..", "fixtures", "raw.xml"))
    @test parse_particles(xml) == [(0.0, 0.0, 0.0, 0.5), (0.5, 0.5, 0.5, 0.5)]
end

function parse_simulation_size(xml)
    simulation_size = findfirst("//SimulationSize", xml)
    parse(Float64, simulation_size["x"]), parse(Float64, simulation_size["y"]), parse(Float64, simulation_size["z"])
end

@testitem "parse_simulation_size" begin
    xml = readxml(joinpath(@__DIR__, "..", "fixtures", "raw.xml"))
    @test parse_simulation_size(xml) == (1.0, 1.0, 1.0)
end
