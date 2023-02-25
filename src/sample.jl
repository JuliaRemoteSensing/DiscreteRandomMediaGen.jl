export sample_sphere

@doc raw"""
Sample from the particle configuration described by `xml` a sphere of radius `R` centered randomly.

When a particle intersects with the sample sphere, the intersection volume is determined via:

```math
\begin{aligned}
V & =V\left(R_1, h_1\right)+V\left(R_2, h_2\right) \\
& =\frac{\pi(R+r-d)^2\left(d^2+2 d r-3 r^2+2 d R+6 r R-3 R^2\right)}{12 d}
\end{aligned}
```

Then the particle is accepted by probability ``\frac{V}{V_{\text{particle}}}``.

Parameters:

- `xml`: the XML Document describing the particle configuration.
- `R`: the radius of the sample sphere.
- `seed`: seed for random number generator. Default to `nothing`, which means a random seed will be generated.
- `center`: the center of the sample sphere. Default to `nothing`, which means the center will be randomly generated.
"""
function sample_sphere(xml, R; seed = nothing, center = nothing)
    if !isnothing(seed)
        Random.seed!(seed)
    end

    particles = parse_particles(xml)
    X, Y, Z = parse_simulation_size(xml)

    if 2R > min(X, Y, Z)
        throw(ArgumentError("The sphere radius is too large for the simulation size"))
    end

    if isnothing(center)
        cx, cy, cz = (rand() - 0.5) * X, (rand() - 0.5) * Y, (rand() - 0.5) * Z
    else
        cx, cy, cz = center
    end

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
