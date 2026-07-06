# Barbara Reproduction Notes

This project reproduces Barbara Gravel's distributed-delay predator-prey results.
Most figures use direct simulation of the gamma-chain ODE. Figure 3 uses MatCont
limit-cycle continuation and Floquet multipliers.

## Implemented

- Gamma travel-time kernels for Figure 1.
- Two-patch Rosenzweig-MacArthur model with prey dispersal.
- Gamma distributed delay converted to an ODE system with the linear chain trick.
- Representative time traces and h1-h2 projections for Figure 2.
- MatCont-based limit-cycle continuation for Figure 3.
- Simulation-based phase classification for approximate Figure 4.
- Simulation-based convergence-rate estimates for approximate Figure 5.

## MatCont

MatCont 7p6 is installed locally at:

```text
external/MatCont7p6/
```

Figure 3 starts from simulated phase-locked cycles, initializes MatCont limit-cycle
continuation with `initOrbLC`, continues the branches in mean delay `tau`, and
classifies stability from nontrivial Floquet multipliers.

The Figure 3 script uses `quickMode = true` by default. This keeps the workflow
runnable on a laptop but produces a practical branch sample rather than a dense,
publication-grade continuation. For denser continuation, edit:

```text
scripts/reproduce_fig3_bifurcation_matcont.m
```

and set:

```matlab
options.quickMode = false;
```

or tune `maxNumPoints`, `maxStepSize`, `ntst`, and `ncol` before calling
`run_barbara_fig3_continuation`.

## Main Commands

Run from MATLAB in the project root:

```matlab
Dispersal('fig1')
Dispersal('fig2')
Dispersal('fig3')
Dispersal('fig4')
Dispersal('fig5')
Dispersal('level1')
```

Outputs are written to:

- `results/figures/`
- `results/raw/`
- `results/processed/`

Figure 4 also uses `quickMode = true` by default. Set it to `false` in
`scripts/reproduce_fig4_phase_regions.m` for a denser simulation sweep.
