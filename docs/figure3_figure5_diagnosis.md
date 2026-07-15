# Diagnosis of Barbara Figures 3 and 5

## Bottom line

The failure was primarily in this repository, not in equation (11) of
Barbara Gravel's manuscript.  The corrected model gives a single-patch
period of about 7.33 (the paper reports 7.34), and the analytical state and
parameter Jacobians agree with centered finite differences to approximately
`1e-9`.

The paper is nevertheless under-specified for an exact Figure 5
reproduction: it does not state the initial phase displacement, the precise
definition of phase at finite amplitude, the exponential fitting window, or
the fit-quality rule.  Its sentence saying the far-from-bifurcation trend is
shown in "Fig. 5 a and b" also conflicts with the caption and the next
paragraph, which identify panel (b) as the near-bifurcation exception.  That
reference is almost certainly meant to be panels (a) and (c).

## Figure 3 defects found

1. The branch was not runnable from a clean MATLAB session because all core
   model helpers were absent from the commit.
2. `Dispersal.m` contained an executable `!git switch ...` line inside the
   function header.
3. The legacy `DDDModel.m` had a missing arrival term and placed predation
   outside the paper's `1/epsilon` factor.
4. A 12-interval MatCont mesh was far too coarse for weak coupling
   (`d=0.001`).  The first Newton correction moved seeds to unrelated tau
   values.  Saved branches seeded at tau=0.05 could begin near tau=0.29.
5. Only 55 points were requested.  The saved in-phase and anti-phase curves
   did not cover the paper's interval `0 <= tau <= 7.34`.
6. Forward and backward continuation independently corrected the approximate
   simulation seed, sometimes selecting widely separated anchors.
7. Points were sorted and de-duplicated using tau alone.  That destroys the
   topology of a folded branch and can delete distinct solutions at the same
   tau.
8. Phase was inferred from array indices even though MatCont adapts its time
   mesh.
9. Stability was accepted up to `|m| < 1.001`, shifting stability boundaries,
   and unknown near-unit cases were converted to logical true by the plotter.
10. The exchange-symmetry branch point can be reported by MatCont as a
    `Neutral Saddle Cycle` when finite collocation splits the double +1
    multiplier into a reciprocal pair.  The raw message is now preserved and
    this known numerical label is plotted as the symmetry-breaking BPC.

The repair adds fixed-tau BVP correction before `initOrbLC`, a much finer
collocation mesh, a seed-drift rejection threshold, backward initialization
from the corrected forward anchor, branch-coverage metadata/warnings,
time-mesh-aware phase extraction, topology-preserving run identifiers, and
an honest unknown category near unit Floquet multipliers.

## Figure 5 defects found

1. The script did not use the paper's mean delays.  OCR of the actual legends
   gives panel (a) `tau = 1.25, 1.75`, panel (b) `tau = 2.5, 3.5`, and panel
   (c) `tau = 5.25, 6.25`.  The old code instead used
   `0.08, 0.25, 0.75, 1.5, 5` on one combined axis.
2. Figure 5 does not state the sampled p values.  The repaired script uses
   the nine integer p values explicitly listed for the adjacent Figure 4;
   an exact point-for-point match is impossible without Barbara's source.
3. Peak times were restricted to the requested output grid.  This quantized
   phase and produced repeated values such as `1.154`, `2.094`, and `3.075`
   radians regardless of `p`.
4. The old routine fit an arbitrary 10--85% portion of the whole simulation,
   even when the phase error was non-monotone or had reached the timing-noise
   floor.  The median saved R-squared was only about 0.18.
5. A positive fitted slope was silently changed to rate zero.  Zero has a
   dynamical meaning at a bifurcation, so this converted failed fits into
   false scientific results.

Peak times are now refined below the output-grid spacing.  Figure 5 uses the
solver's adaptive mesh, searches contiguous above-noise log-linear decay
windows, requires `R^2 >= 0.80` and at least a factor-of-two decay, and returns
`NaN` rather than a fake zero when no exponential window is supported.

## Validation performed

- Single-patch period: approximately `7.33` versus `7.34` in the manuscript.
- Maximum analytical-Jacobian errors: approximately `4e-10` (state) and
  `2e-9` (parameters).
- Minimal p=2 MatCont test: all forward/backward anchors pass after the
  backward-anchor repair; typical seed drift is `2e-7` to `5e-3`.
- Moderate p=2 continuation detects the fold near `tau=0.0727`, the
  symmetry-breaking event near `tau=0.151`, and the branch point near
  `tau=0.4117`, consistent with the manuscript's stated transitions near
  `0.16 +/- 0.02` and `0.42 +/- 0.01`.
- At p=10, the recovered Figure 5 tau pairs produce anti-phase behavior for
  the first panel and in-phase behavior for the last.  Valid fitted rates are
  substantially faster for representative anti-phase cases than for the
  in-phase cases, matching the paper's qualitative claim.

The full Figure 3 and Figure 5 commands are intentionally expensive.  They
now default to scientifically defensible settings rather than returning a
fast but misleading picture.
