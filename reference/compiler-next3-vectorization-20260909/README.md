# Automatic integer SLP prototype

Current implementation supersedes the initial unvalidated floating-point
prototype. It automatically packs ordinary scalar source arithmetic; this
is straight-line superword-level parallelism (SLP), **not loop vectorization**.
It is opt-in through `compiler.cfg.slp:automatic-slp?` and remains off by
default. The SSA optimizer hook invokes `auto-vectorize` after copy propagation
and optional integer LICM, before dead-code elimination.

## Semantics and scope

Eligible operations are raw machine-width integer add/subtract and bitwise
AND/OR/XOR. Checked fixnum operations, all floating-point operations, memory
instructions, calls, allocation, GC and branches are excluded. FP packing
could change the first enabled trap or accrued flags even without arithmetic
reassociation, so all FP operations remain scalar. No claim of FP vectorization
is made.

Two independent expression trees in one arithmetic-only region must have
matching operators and lane order, with single-use internal definitions.
The earlier result may not be consumed before the later root. Gather leaves
may not depend on any removed definition. Global use counts include implicit
GC-map operands. Calls/stores/GC/branches end the region; no memory operation
is widened or moved and no loop/reduction order changes. The original scalar
outputs are extracted into their original SSA identities.

Targets must have 64-bit cells and advertise every required unsigned-64x2
operation, gather and extraction. The cost test counts the entire paired
tree: each unique leaf pair budgets two gather instructions plus two possible
tagged/integer conversions, and five instructions cover extraction, output
tagging and moves. The saved arithmetic count must strictly exceed that
budget. Regions with more than 256 arithmetic definitions are rejected;
currently only one pair is packed per region.

## Ordinary-source witness

`kernels.factor` defines a two-channel, twelve-round keyed XOR/add mixing
kernel using only scalar fixnum operations. It contains no vector type or SIMD
intrinsic. This additional representative scalar microkernel is **not** a
claim that an existing 26-workload benchmark was vectorized.

The native ARM checked gate uses independently compiled OFF/ON temporary word
handles invoked dynamically, plus an arbitrary-precision scalar loop with an
explicit signed-fixnum-width reduction. All 4,096 combinations of zero, small
positive/negative values, and both fixnum endpoints agree. SSA, interval and
final allocation value-flow checks are enabled. Manual IR tests additionally
cover short unprofitable chains, early consumers, shared internal uses,
call barriers, checked arithmetic and FP exclusion.

The actual compiled ordinary-source word changes from **272 to 208 bytes**.
`packed-assembly.txt`, decoded from the captured installed code with Homebrew
LLVM's `llvm-mc --disassemble --triple=aarch64`, contains twelve `eor v*.16b`
and twelve `add v*.2d` instructions. It also retains all six input lane
insertions, four scalar untag operations, two lane extractions and two result
tag operations; packing overhead has not been omitted from the size comparison.
Raw installed bytes and scalar/packed assembly are retained alongside logs.

The original Factor disassembler attempt could not locate libcapstone; it
was removed from the successful gate. LLVM decoded the already-captured raw
bytes independently. No library installation or backend source change was
needed.

Runtime measurements, existing-corpus coverage, and native x86 confirmation
remain pending. Code-size reduction and instruction selection alone do not
establish an execution-time win. Array tails, aliasing and unaligned access
are structurally unaffected because this pass does not transform memory or
loop iteration; additional wrapper cases remain to be exercised.
