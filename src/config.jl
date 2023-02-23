export SimulationConfig

@doc raw"""
Configuration for a simulation.

Parameters:

- `model`: the interaction model to be used. Default to `HardSphereModel()`.
- `volume_fraction`: volume fraction of particles. Default to `0.2`.
- `radius_function`: a function for generating particle radii. Default to `() -> 0.5`.
- `cell_size`: size of the peoriodic cell. Default to `40`. This leads to `256,000` particles generated in total, which should be enough in most cases.
- `collisions_per_step`: average collisions for each particle before the simulation stops intermediately and checks convergence. Default to `20`.
- `mean_free_time_threshold`: threshold for convergence of mean free time. Default to `1e-3`.
- `maximum_steps`: maximum number of simulation steps. Default to `100`.
- `save_snapshots`: path prefix to save snapshots of the simulation. Default to `""`, which means no snapshots will be saved. If not empty, snapshots will be named as `$(save_snapshots)/snapshot.$step.png` for each step.
- `save_gif`: path to save a gif of the simulation. Default to `""`, which means no gif will be saved. If not empty, a gif will be saved to `$(save_fig)/snapshot.gif`.
- `framerate`: framerate of the gif. Default to `10`.
- `seed`: seed for random number generator. Default to `nothing`, which means a random seed will be generated.
"""
Base.@kwdef struct SimulationConfig{Model <: AbstractModel, F <: Function}
    model::Model = HardSphereModel()
    volume_fraction::Float64 = 0.2
    radius_function::F = () -> 0.4
    cell_size::Int = 40
    collisions_per_step::Int = 20
    mean_free_time_threshold::Float64 = 1e-3
    maximum_steps::Int = 100
    save_snapshots::String = ""
    save_gif::String = ""
    framerate::Int = 10
    seed::Union{Nothing, Int} = nothing
end
