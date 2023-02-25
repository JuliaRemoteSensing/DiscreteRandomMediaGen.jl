export generate

function generate(cfg::SimulationConfig)
    mktempdir() do tmpdir
        current_dir = pwd()
        end_xml = nothing

        try
            cd(tmpdir)
            N = cfg.cell_size^3 * 4
            radii = [cfg.radius_function() for _ in 1:N]
            V̄ = 8 * sum(radii .^ 3) / N
            density = √2 * cfg.volume_fraction / FCCVolumeFraction / V̄
            if isnothing(cfg.seed)
                run(`$(dynamod()) -m0 -d$density -C$(cfg.cell_size) --i1 0 -oconfig.0.xml`)
            else
                run(`$(dynamod()) -m0 -d$density -C$(cfg.cell_size) -s$(cfg.seed) --i1 0 -oconfig.0.xml`)
            end
            start_xml = readxml("config.0.xml")
            modify_particles!(start_xml, radii, cfg.model)
            modify_interaction!(start_xml, cfg.model)
            write("config.0.xml", start_xml)

            step = 0
            mft = 0.0
            savedir = isabspath(cfg.save_snapshots) ? cfg.save_snapshots :
                      joinpath(current_dir, cfg.save_snapshots)
            if !isempty(cfg.save_snapshots)
                fig, _, _ = particleplot(start_xml, figure=(resolution=cfg.resolution,))
                save(joinpath(savedir, "snapshot.$step.png"), fig)
            end

            while step < cfg.maximum_steps
                if isnothing(cfg.seed)
                    run(`$(dynarun()) config.$step.xml -c$(cfg.collisions_per_step * N) -oconfig.$(step + 1).xml`)
                else
                    run(`$(dynarun()) config.$step.xml -c$(cfg.collisions_per_step * N) -s$(cfg.seed) -oconfig.$(step + 1).xml`)
                end
                step += 1
                xml = readxml("config.$step.xml")
                if !isempty(cfg.save_snapshots)
                    fig, _, _ = particleplot(xml, figure=(resolution=cfg.resolution,))
                    save(joinpath(savedir, "snapshot.$step.png"), fig)
                end

                mft′ = parse(Float64, findfirst("//Simulation", xml)["lastMFT"])
                Δmft = abs(mft′ - mft) / mft′
                mft = mft′
                @info "step = $step, Δmft = $Δmft"
                if Δmft <= cfg.mean_free_time_threshold
                    @info "mean free time converged!"
                    break
                end
            end

            if !isempty(cfg.save_gif)
                xml = Observable(readxml("config.0.xml"))
                fig, _, _ = particleplot(xm; figure=(resolution=cfg.resolution))
                savedir = isabspath(cfg.save_gif) ? cfg.save_gif :
                          joinpath(current_dir, cfg.save_gif)

                record(fig, joinpath(savedir, "snapshot.gif"), 0:step,
                       framerate = cfg.framerate) do t
                    xml[] = readxml("config.$t.xml")
                end
            end

            end_xml = readxml("config.$step.xml")
        catch e
            @error "error occured during simulation" exception=e
        finally
            cd(current_dir)
        end

        return end_xml
    end
end

function add_property!(xml, type, units, name)
    properties = findfirst("//Properties", xml)
    property = EzXML.ElementNode("Property")
    property["Type"] = type
    property["Units"] = units
    property["Name"] = name
    EzXML.link!(properties, property)
end

function modify_particles!(xml, radii, model)
    species = findfirst("//Species", xml)
    species["Mass"] = "M"
    add_property!(xml, "PerParticle", "Mass", "M")

    interaction = findfirst("//Interaction", xml)
    interaction["Diameter"] = "D"
    add_property!(xml, "PerParticle", "Length", "D")

    if model isa StickyHardSphereModel
        add_property!(xml, "PerParticle", "Energy", "WD")
    end

    foreach(zip(radii, findall("//Pt", xml))) do (r, particle)
        particle["D"] = 2 * r
        particle["M"] = r^3
        if model isa StickyHardSphereModel
            particle["WD"] = -log(12 * model.τ * SHSWellWidth[])
        end
    end
end

modify_interaction!(xml, ::HardSphereModel) = xml

function modify_interaction!(xml, ::StickyHardSphereModel)
    interaction = findfirst("//Interaction", xml)
    interaction["Type"] = "SquareWell"

    # We use a very narrow well to simulate the δ-function
    interaction["Lambda"] = 1 + SHSWellWidth[]
    interaction["WellDepth"] = "WD"

    xml
end

@testitem "DynamO simulation" begin

@testset "can be reproduced" for model in [HardSphereModel(), StickyHardSphereModel(3.0)]
    cfg = SimulationConfig(model = model,
                           cell_size = 8,
                           collisions_per_step = 5,
                           maximum_steps = 1,
                           seed = 42)
    xml1 = generate(cfg)
    xml2 = generate(cfg)
    @test parse_particles(xml1) == parse_particles(xml2)
end end
