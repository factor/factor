# Ordinary Factor call clobber verification

Surgical fix: `dfe08fc9bd` (integrated as `fe96977cee`). The verifier suite
passes with a callback raw pointer kept in its ABI spill slot across a Factor
call. Two corruptions, a missing post-call reload and a stale post-call store,
are rejected. Reloading the prepatch verifier accepts both corruptions; the
retained log prints `OLD-CHECKER ACCEPTED BOTH CORRUPTIONS`.

The original run used the two working verifier files subsequently committed
in that fix; its manifest records the parent revision and dirty paths. The
three exact scripts are retained with SHA256 hashes. To reproduce the original
command, place those scripts at the `/tmp/` paths referenced by the driver,
then use the matching source, VM and image recorded in `environment.json`.
The driver intentionally finishes with the old verifier loaded in its
disposable process. This is a negative control, not a production setting.
