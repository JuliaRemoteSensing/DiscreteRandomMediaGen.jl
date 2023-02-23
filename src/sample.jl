export sample_sphere

"""
Sample from the particle configuration described by `xml` a sphere of radius `R` centered randomly.

Parameters:

- `xml`: the XML Document describing the particle configuration.
- `R`: the radius of the sample sphere.
- `seed`: seed for random number generator. Default to `nothing`, which means a random seed will be generated.
"""
function sample_sphere(xml, R, seed = nothing)
    if !isnothing(seed)
        Random.seed!(seed)
    end

    particles = parse_particles(xml)
    X, Y, Z = parse_simulation_size(xml)

    if 2R > min(X, Y, Z)
        throw(ArgumentError("The sphere radius is too large for the simulation size"))
    end

    cx, cy, cz = (rand() - 0.5) * X, (rand() - 0.5) * Y, (rand() - 0.5) * Z

    sampled_particles = NTuple{4, Float64}[]
    for dx in -1:1, dy in -1:1, dz in -1:1
        for (x, y, z, r) in particles
            d = sqrt((x + dx * X - cx)^2 + (y + dy * Y - cy)^2 + (z + dz * Z - cz)^2)
            if d < R - r
                push!(sampled_particles, (x + dx * X, y + dy * Y, z + dz * Z, r))
            elseif d < R + r
                intersection = π * (R + r - d)^2 *
                               (d^2 + 2d * r - 3r^2 + 2d * R + 6r * R - 3R^2) / 12d
                if rand() < intersection / (4 / 3 * π * r^3)
                    push!(sampled_particles, (x + dx * X, y + dy * Y, z + dz * Z, r))
                end
            end
        end
    end

    sampled_particles
end

@testitem "particle sampling can be reproduced" begin
    cfg = SimulationConfig(model = HardSphereModel(),
                           cell_size = 8,
                           collisions_per_step = 5,
                           maximum_steps = 1)
    xml = generate(cfg)
    sample1 = sample_sphere(xml, 5.0, 42)
    sample2 = sample_sphere(xml, 5.0, 42)

    @test sample1 == sample2
end
