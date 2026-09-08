# Native Linux x86-64 load-all / test-all validation

Validated source: `9d57d73a4e5c57c860c49ab01ed517299604f804`.

The test host is `agent1`, running Ubuntu 26.04 on native x86-64 hardware.
A dedicated checkout at `/home/erg/factor-linux-validation-20260908` contains
its own VM, images, libraries, and test services. The existing server checkout
and existing services were not used for destructive database tests.

## Fixes

- `0e95fc5573`: use versioned Linux runtime SONAMEs in 22 bindings. Runtime
  packages do not generally supply the unversioned development symlinks.
- `4a1b1f8cbd`: accept the VM's structured proactive callstack overflow in the
  near-guard GC regression and verify GC still works after recovery. The test
  remains enabled on Linux and macOS; unexpected exceptions still fail.
- `06356d98d7`: resolve GTK3 OpenGL functions through the registered libepoxy
  handle, including Linux's `libepoxy.so.0`, with symbol-resolution tests.
- `9d57d73a4e`: skip manually corrected GdkPixbuf, Pango, and GTK2 functions
  during GIR generation instead of forgetting and recreating their words.
  Existing callers retain the corrected bindings across reloads.

The initial complete sweep loaded 3,352 vocabularies with no compiler errors,
passed help lint, and ran 1,240 test files with 22 failures and no compiler
errors. These comprised one stack regression, six GTK image failures, eleven
Pango text/editor failures, and four GLU failures caused by a missing
`libOpenGL.so.0` dependency. Two deliberately generated `fake` notifications
in `tools.test` are excluded from the actual failure count.

The three binding-identity regression tests fail against the old bindings and
pass with the fix. Targeted GTK image, text/editor, GLU triangulation, and GIR
loader tests pass on native Linux. The portable GIR regressions also pass on
ARM64 macOS. All six native VM stack-safety subprocess tests pass on the final rebuilt VM.

## Final results

| Check | Result | Time |
| --- | --- | --- |
| Fresh native bootstrap | Pass | 127.174 s |
| Strict `load-all` | 3,354 vocabularies, 0 compiler errors | 414.851 s |
| `help-lint-all` | 0 failures | 8.427 s |
| Full `test-all` | 1,247 files, 0 failures, 0 compiler errors | 934.254 s |
| Native VM stack safety | 6 tests, all pass | 117.415 s |

The sweep includes all seven SIMD test files (compiler intrinsics/propagation,
matrices, vectors, cords, extensions, and vector intrinsics). The final saved
image also passes the previously failing GTK/GLU tests directly, without
reparsing or repairing its callers first. `results.json` contains the command,
exit status, and elapsed time for every stage; `provenance.json` records a clean
tracked source tree and hashes of the VM and images.

The temporary PostgreSQL, Redis, and Xvfb services have been stopped; see
`services-stopped.json`.

## Reproduction

1. Check out the validated source in a clean Linux x86-64 directory.
2. Build with `make -j8 linux-x86-64` and generate a matching
   `boot.unix-x86.64.image` from that source using `bootstrap.image`.
3. Supply runtime dependencies, a display, and isolated PostgreSQL/Redis test
   instances. `start-services.py` records the setup used here; it requires a
   new data directory and unused ports/display. PostgreSQL uses port 64578,
   Redis uses port 64580, and Xvfb uses display `:98`.
4. Put the stage drivers under `validation/`, adjust the checkout paths in
   `load-all.factor`, and run `python3 validation/run-final.py`.
   It performs fresh bootstrap, strict `load-all`, `help-lint-all`, and ordinary
   `test-all` in sequence, stopping on any failure. No test exclusion list or
   failure suppression is used. The annotations only record progress/failures.
5. Run `python3 validation/collect-provenance.py` to record the source,
   compiler/libc versions, artifact hashes, and dependency archive hashes.

Dependencies absent from the base host were downloaded with `apt-get download`
and extracted with `dpkg-deb -x` into `validation/libraries`, without system
package installation: libudis86-0, libblas3, libglu1-mesa, libgtk2.0-0t64,
libglut3.12, and libopengl0. BLAS also needs its `blas` subdirectory on
`LD_LIBRARY_PATH`. PCRE 8.45 was built locally from the official
`pcre-8.45.tar.bz2` release with UTF/Unicode properties enabled because the host
has PCRE2 but no PCRE1 package. The runner supplies these private library paths.

Raw logs, images, package archives, and build products are retained in the
remote checkout's `validation/` directory. Initial results are preserved in
`validation/initial/`; the small result summaries and reproducible drivers are
included here. Existing unrelated local compiler/SIMD edits are outside this
validated source snapshot.
