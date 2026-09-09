# ARM64 varargs alignment regressions

Three independent alignment errors are repaired:

* Indirect aggregate copies and hidden result buffers used cell alignment, even when the C type required 16. A preceding 24-byte aggregate copy exposes the 8-byte misalignment. Allocate each buffer at `max(cell, c-type-align)`.
* SIMD C types set their ordinary alignment to 16 but omitted their first-member alignment. This gave vector-first structs size24/alignment8 instead of C size32/alignment16, and under-aligned unions. Set both alignments to16.
* macOS anonymous argument groups flattened to integer chunks lost the aggregate alignment. Preserve the original argument alignment in group metadata and apply it before the first chunk. Indirect aggregates use the pointer alignment at the call site; their separately allocated copy retains the aggregate alignment.

`before.log` reports three failing Windows ABI pointer probes (each expected0, got8): named HVA direct/indirect and hidden-X8 return area. `after.log` reports zero failures/compiler errors. Windows-generated C instructions were assembled as Mach-O after symbol/directive translation only; the body masks the actual incoming X1 or X8 pointer. The LLVM IR and both assemblies are included. This is **macOS-hosted Windows ABI evidence**, not native Windows qualification.

`native-before.log` reports six failures in the native C-backed outgoing suite. `native.log` runs the same suite after repair and reports zero failures/compiler errors. Tests independently compare C sizeof/alignment, pass vector-first structs and unions after an anonymous integer, check the hidden result pointer, and read a union with a synthetic macOS cursor after an eight-byte slot. Ordinary outgoing controls remain included.

Build the native fixture from this worktree with `clang -dynamiclib -O2 vm/ffi_test.c -o libfactor-ffi-test.dylib`. `build-oracle.py` builds the Windows-target C oracle. Run each Factor harness with `/Users/erg/factor.worktrees/arm64-varargs-entry/factor -no-user-init -i=/Users/erg/factor/reference/arm64-varargs-20260908/final.image`; the native harness uses this worktree as `-resource-path`, the Windows harness uses `/Users/erg/factor`. `fix.factor` installs the exact compiler helper changes and updates the existing float-4 CType instance's align-first slot; the production SIMD constructor sets that slot for every vector CType. The old image already contains the separately verified SIMD literal-boxer fix.

The inline assembly C pointer probes require GCC or Clang on ARM64; the fixture reports availability explicitly. Windows MSVC does not compile GNU vector/inline-assembly probes. No native Windows result is claimed.
