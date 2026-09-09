# Unpromoted spectral-norm recoloring diagnostic

This is an evidence-only experiment. It is not a production optimization and
is not part of the frozen combined candidate `eccfc0accc`. Production chordal
selection remains commit `29dec39c55`, with no additional recoloring pass.

The parent ran `../spectral-relax.factor` on ARM using the matching VM and fresh
image recorded in `status.json`, full `refresh-all`, GVN off, rematerialization
on, and SSA/interval/final-value checks on. The process exited zero. The script
compiles spectral norm and prints its physical CFG and metrics; it does not
execute spectral norm or measure its runtime. The process counters include
startup, compilation and diagnostic printing and are not speed measurements.

| Metric | Retained baseline | Diagnostic relaxation |
| --- | ---: | ---: |
| Final IR copies | 92 | 58 |
| Final IR stores | 23 | 22 |
| Final IR reloads | 23 | 22 |
| Generated code bytes | 3392 | 3248 |
| Vertices recolored | 0 | 59 |

Baseline evidence is `../spectral-baseline/output.log`. IR copies are not an
emitted-instruction count. The reduced code and transport counts justify
further investigation, but do not establish a runtime improvement.

## Legality audit

The prototype starts with the complete, valid finite-bank color map produced
by ordinary preference coloring. It visits each vertex once in reverse MCS
order and considers colors already assigned to its affinity partners. The
production affinity builder admits only graph vertices in the same register
class, so these candidate colors belong to the vertex's bank. This bank
property is an assumption inherited from that builder, not an explicit check
inside the experimental helper; the helper is not a general public API for
arbitrary affinity maps.

For every vertex, the prototype recomputes all interference-neighbor colors
from the current map. It accepts only an unoccupied color and changes just that
vertex. Therefore every incident edge stays legal, and all other edges are
unchanged. Earlier recolorings are visible to later decisions. It changes no
interference edges, phi identities, memory homes, operand phases, or SSA
transport rules. Machine constraints encoded by the original graph and bank
are preserved; it makes no claim for constraints absent from that model.

The selected color must strictly increase the sum of weights to same-colored
affinity partners. The production affinity graph is symmetric, so this also
strictly increases the global undirected affinity objective. Ties do not cause
recoloring. This proves monotonicity for the existing weighted objective, not
optimality or reduced executed work. Loop-depth weights approximate dynamic
frequency, and different legal colors can affect two-address emission and
parallel-copy cycles beyond this objective.

The existing PEO certificate still concerns the unchanged graph; the
post-selection interval legality and final symbolic value-flow checks ran on
the experimental assignment. One successful CFG is insufficient for promotion:
independent mutation/legality tests, full compiler and native callback/GC
coverage, compile-cost measurements, and matched executed-work measurements
would still be required. None are waived by this archive.

`manifest.json` hashes the exact script, production source, and raw evidence.
The script was untracked at execution time; the runner's empty `source_status`
does not establish that its bytes belonged to the recorded Git tree. The
separately recorded script SHA-256 supplies that missing provenance.
