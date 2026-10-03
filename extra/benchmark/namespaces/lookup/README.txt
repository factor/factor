Namespace lookup and bootstrap comparison

Run this vocabulary in an original image and an image bootstrapped with
indexed namespaces, using the same VM and checkout for both runs:

  factor.com -i=<image> -resource-path=C:/factor -no-user-init -run=benchmark.namespaces.lookup

Each row measures 200,000 reads at the indicated depth of owned scopes.
Scope construction is outside the timer. There is one warmup and five
measured samples, with GC before each sample; the CSV reports the median
in ns/read. Values accumulate into a global sink to prevent dead-read
removal. The benchmark uses the image's actual get and with-scope words.
The parent benchmark.namespaces vocabulary measures scope-heavy workloads.

Recorded Windows x86.64 results, October 2, 2026, are in baseline.csv and
indexed.csv. Reading an outer binding at depth 16 falls from 53.155 to
8.020 ns/read; at depth 64 it falls from 223.290 to 7.312 ns/read.
Nearest-scope reads usually cost about 30% more (5.862 to 7.752 ns/read at
depth 1). Global and missing reads at shallow depths can also regress.
Short microbenchmarks vary; bootstrap timings measure the target workload.

Bootstrap measurements use fresh windows-x86.64 stage1 images and default
stage2 components: math compiler threads io tools ui ui.tools unicode help
handbook. Use -no-user-init, a separate -output-image for each run, and
run variants serially. The bootstrap.stage2 core-bootstrap-time global
reports loading and compilation time in nanoseconds, excluding image save.
Keep the VM, sources and component selection fixed between variants.

bootstrap.csv records:

  Original namespace stack:      294.220 seconds (4:54)
  Indexed namespaces:           266.355 seconds (4:26)
  Indexed namespaces, repeat:    266.115 seconds (4:26)

The repeat is 9.6% faster. Both indexed runs use shared binding cells and
copy-on-write indexes. These timings precede the failed-hash insertion
and mutable-key cleanup fixes; the getter is unchanged by those fixes.

The implementation preserves shared mutation across continuations and
threads. Caller-supplied and publicly exported assocs are read live.
Captures copy scope topology and share frames, values and indexes; adding
a key to a captured frame invalidates other indexes. borrowed? and shared?
track aliasing and mutation; Factor's GC manages memory lifetime.

Validation without load-all: all 4,336 core tests passed across 92 test
vocabularies. All 697 supported basis test vocabularies ran 15,414 tests,
with long tests enabled. All 26 long deployment checks passed using a
fresh stage1 image. Native libraries were found via C:/factor/dlls64-out
on the test process's PATH. Remaining failures reproduce with original
namespaces: 113 disassembler cases need libudis86.dll, and three PostgreSQL
test files need database configuration. A test driver filename assertion
was corrected and all four deployment backend tests passed on rerun.

Regression coverage includes 3,000 deterministic operations compared with
a vector of mutable assocs, repeated continuation restoration, inherited
thread bindings, direct assoc insertion/deletion, failed hash insertion
after capture, and scope cleanup with mutable keys. Both codegen cases
that exposed the mutable-key cleanup problem pass in the full suite.
