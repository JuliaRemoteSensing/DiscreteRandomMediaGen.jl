export particleplot

@recipe(ParticlePlot, cfg) do scene
    Attributes()
end

function Makie.plot!(pp::ParticlePlot{<:Tuple{EzXML.Document}})
    xml = pp[1]

    x = Observable(Float64[])
    y = Observable(Float64[])
    z = Observable(Float64[])
    r = Observable(Float64[])

    function update_plot(xml)
        particles = parse_particles(xml)
        new_x = map(x -> x[1], particles)
        new_y = map(x -> x[2], particles)
        new_z = map(x -> x[3], particles)
        new_r = map(x -> x[4], particles)

        x[] = new_x
        y[] = new_y
        z[] = new_z
        r[] = new_r
    end

    Makie.Observables.onany(update_plot, xml)
    update_plot(xml[])
    meshscatter!(pp,
                 x,
                 y,
                 z,
                 markersize = r,
                 color = 1:length(x[]),
                 markerspace = :data)

    pp
end
