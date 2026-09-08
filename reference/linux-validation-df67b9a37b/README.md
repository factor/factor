# Linux validation after the SIMD/VM follow-ups

Source snapshot: `df67b9a37b71792e473892f292a3ef8e9bc38c98`.

This run follows the [earlier clean Linux run](../linux-validation-20260908/README.md)
and includes three subsequent code/test commits:

- `7a30958828`: convert signed integer minima without signed overflow in the VM.
- `983bd98033`: correct SIMD byte shifts and NaN-safe add/sub fallbacks.
- `f5ccd7e87a`: retain SIMD fuzz inputs, results, and exceptions with `tools.test.fuzz`.

Validation uses a clean dedicated checkout at
`/home/erg/factor-linux-validation-df67b9a37b` on `agent1` (native Linux x86-64).
The uncommitted value-numbering/float-conversion refactor in the shared macOS
working tree is outside this snapshot.

The VM was rebuilt with `make -j8 linux-x86-64`. A matching boot image was
generated from the committed source, followed by fresh native bootstrap,
strict `load-all`, `help-lint-all`, and ordinary `test-all`.

## Results

| Check | Result | Time |
| --- | --- | --- |
| Fresh native bootstrap | Pass | 123.029 s |
| Strict `load-all` | 3,354 vocabularies; 0 compiler errors | 387.040 s |
| `help-lint-all` | 0 failures | 11.779 s |
| Full `test-all` | 1,247 files; 0 failures; 0 compiler errors | 924.150 s |

All seven SIMD test files pass. The four deliberate `fake` failure notifications
come from test-framework and SIMD fuzz self-tests; the final failure count is
zero. No additional source fixes were needed for this snapshot.

The temporary PostgreSQL, Redis, and Xvfb instances have been stopped; see
`services-stopped.json`.

## Reproduction and artifacts

Use the drivers in `../linux-validation-20260908/`, replacing the old checkout
path with `/home/erg/factor-linux-validation-df67b9a37b` in `load-all.factor`.
Copy `summarize-final.py` from this directory for the final result summary.
Run `collect-provenance.py` before it, then stop the test services.
The run uses the same private runtime-library prefix and dependency archives as
the earlier validation. PostgreSQL, Redis, and Xvfb run in isolated test
instances on ports 64578/64580 and display `:98`.

The full suite passed without test exclusions or failure suppression. No
FFI/shared-library exceptions were needed.

Raw build/bootstrap/load/test logs and generated images are retained under the
remote checkout and its `validation/` directory. `results.json` records stage
commands and results; `provenance.json` records the source, artifact hashes,
compiler/libc versions, and dependency hashes.
