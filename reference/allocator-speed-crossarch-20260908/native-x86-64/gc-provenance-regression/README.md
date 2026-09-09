# Native moving-GC provenance regression

The standalone regression generates and executes machine code under all four
allocators. Each allocator handles 20 fresh heap objects in a plain coalesced
`tagged>integer` case and 20 more with a nonzero derived-pointer offset. Object
identity must survive the collection, for 160 checks in total.

On native x86-64 (`agent1`, AMD Ryzen 9 7950X3D), the first corrected draft passed
the plain case but failed the offset case under linear scan. Its final GC map
assigned the base and offset-derived pointer the same spill location. The new
implicit GC-root use tracking handled vreg instructions, but `##call-gc` is a
plain instruction and did not enter that method.

Adding the explicit `##call-gc record-insn` method fixed the regression. All four
allocators returned true for both cases, and the process exited 0. SHA-256 hashes
of all three tested compiler files match final commit `d1bfcc67b9` exactly.

Both draft versions, exit statuses and logs are retained. `*-source.patch`
contains the exact change against source `233db947df`; `*-source-manifest.json`
records the tested compiler file hashes. Replay by applying the chosen patch to
that source revision and running `moving-gc.factor` from a matching image. The
actual native experiments loaded those three source files into separate fresh
processes from the original prepared image, leaving the baseline source tree
untouched. The large VM/image artifacts remain in the remote isolated directory.

This executed regression complements the independent final register-value
verifier and the broader 26-workload benchmark checks. Performance measurements
must use the final correction in both baseline and candidate.
