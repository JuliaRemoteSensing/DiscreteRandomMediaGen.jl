export AbstractModel, HardSphereModel, StickyHardSphereModel

abstract type AbstractModel end

@doc raw"""
A hard sphere (HS) model:

```math
\mathrm{e}^{-u(r)}=\left\{
\begin{aligned}
0 &\quad r \le d \\
1 &\quad r > d
\end{aligned}
\right.
```
"""
struct HardSphereModel <: AbstractModel end

@doc raw"""
A sticky hard sphere (SHS) model specified by Eq. (8.4.37) in Tsang et al. (2001):

```math
\mathrm{e}^{-u(r)}=\left\{
\begin{aligned}
\frac{d}{12\tau}\delta(r-d) &\quad r \le d \\
1 &\quad r > d
\end{aligned}
\right.
```

Parameters:

- `τ`: the stickiness parameter. This has effect only for the `SHS` model. Default to `1.0`.

  ``\tau \ge \frac{2-\sqrt{2}}{6}`` should hold to ensure that Eq. (8.4.22) in Tsang et al. (2001) has valid solutions.
"""
Base.@kwdef struct StickyHardSphereModel <: AbstractModel
    τ::Float64 = 1.0
end
