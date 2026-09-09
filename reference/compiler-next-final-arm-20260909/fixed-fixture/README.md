# Corrected manual memory-home fixture

Test fix96ca4b90f2 (integrated480face343), evidence24d5bbc005. The fixture
uses runtime peeks instead of integer constants, preventing rematerialization
from invalidating its manually imposed stack homes. Production is unchanged.
Explicitly loaded backtracking subtree passes with final-value and SSA checks
on in both rematerialization modes: ON12.408s, OFF11.392s. This independently
covers the changed test file alongside the reused c694 linear-scan suite.
Expected test source SHA256:
`3bc5c4808cb2b1be9b0778b8af23891bad60fc4538706da9a1167065f98fb5ec`.
