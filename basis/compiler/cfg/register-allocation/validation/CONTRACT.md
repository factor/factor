# Factor allocator constraint and validation contract

An allocator consumes the original SSA CFG and produces physical instructions
ready for `build-stack-frame` and code generation. The contract is portable
across the supported targets; it is more conservative than an individual
target's most permissive instruction encoding.

## Registers, representations and locations

- `rep-of` is the virtual value's representation. `reg-class-of` selects the
  bank, and `rep-size` selects the number of bytes that must survive a move.
- Tagged values and integers share `int-regs`. Scalar floating values and
  SIMD values share `float-regs`: allocating a scalar does not create an
  independent register beside a live vector in that same physical register.
- A bank is a subset of `admissible-registers`. Reserved machine registers
  must stay reserved; a CFG requiring a frame pointer excludes `frame-reg`.
  A reduced-bank test must supply valid, unique registers from each used
  class. It may not silently expand the bank when pressure becomes difficult.
- Spill slots occupy one byte-addressed memory area across representations.
  Size, alignment and partial overlap matter. A scalar save of a scratch
  register cannot preserve a live vector's upper lanes.

## Instruction timing and operand restrictions

- In the existing SSA interference convention, ordinary instructions read
  their first input early. Remaining inputs are late, and conflict with
  outputs. This is intentional: `cpu.x86:two-operand` rejects a destination
  equal to the second source when it differs from the first source.
- `def-is-use-insn` (`##box-alien`, `##box-displaced-alien`, and
  `##unbox-any-c-ptr`) makes **all** inputs late. Its documented contract
  requires outputs distinct from all inputs.
- Instruction temporaries conflict with all inputs, outputs, other
  temporaries and values live through the instruction. They are registers,
  never spill-slot substitutes. Existing interval construction conservatively
  reserves the whole instruction point.
- The IR has no general operand field encoding LLVM-style arbitrary fixed
  registers, register tuples, early-clobber flags or tied operand numbers.
  Do not claim these unsupported forms are implemented. Target two-address
  ties are expanded by the emitter with copies; the allocator preserves the
  first-input/late-input restrictions above.
- Multiple simultaneous outputs occupy distinct physical locations. The
  allocator must preserve operand order and the distinction between uses,
  definitions and scratch temporaries.

The current global live-interval builder instead uses closed instruction
points: inputs and outputs at `n` conservatively interfere. This remains
correct but can exceed the minimum register pressure permitted by the phase
convention above. A claim of optimal SSA coloring must identify which pressure
model it uses. A phase-aware interval extension also needs phased assignment:
rename incoming uses before expiration, then activate and rename outputs and
temporaries. Changing overlap endpoints alone would break operand assignment.

## Calls, ABI slots and collection

- `clobber-insn` inputs are consumed in spill locations, including a value
  whose only use is at that instruction. Removing its register fragment does
  not remove the ABI memory obligation.
- `hairy-clobber-insn` also defines outputs in spill locations. This includes
  alien calls, callbacks and `##unbox-long-long`. Ordinary `##box`/`##unbox`
  clobbers can retain their newly defined destination (`keep-dst?`).
- ABI `reg-inputs`, `stack-inputs` and `reg-outputs` retain their ordered
  descriptors; assignment changes the virtual operand to its spill location.
  The ABI emitter transfers those slots to/from the required native ABI
  registers and stack offsets. This is the existing fixed-register contract.
- GC root and derived-base metadata are implicit uses. Tagged bases remain
  live through collection and interfere with distinct derived addresses.
  Explicit `##call-gc` is an `insn`, not a `vreg-insn`; it still has these uses.
- Collection updates only named root/derived spill locations. Other copies
  of a moving pointer become stale. A derived slot must reference the correct
  rooted base, and must not overlap a tagged root slot. Only proven identical
  bits may collapse a derived value and base into a single tagged root.
- Coalescing leaders represent storage reuse as well as value aliases.
  Leader equality alone is not proof that two original values are equal.
  Keep original bitcast/copy provenance for GC analysis.

## SSA and lowering

- Phi operands are uses on individual predecessor edges. The outputs of
  simultaneous phis become available together at the successor. Loop-carried
  cycles require true parallel-copy semantics, including register and stack
  cycles and critical-edge splitting.
- Snapshot checking precedes any destructive SSA rewrite. Original ordinary
  instruction identities and operand order must survive assignment. Register
  moves and spill/reload instructions transport original symbolic values.
- Rematerialization must preserve original instruction identity in its recipe
  and notify the existing observer for each emitted clone. The verifier
  independently checks the immutable literal and transport representation.

## Algorithm evidence

Native results and final value-flow verification are independent of policy.
To distinguish a real algorithm path from a dormant implementation, each new
allocator also exposes `allocator-statistics` containing:

- `algorithm`: a stable implementation identifier;
- `fallback-count`: zero for the full allocator on the supported contract;
- integer work counters for its actual stages (including successful and
  unsuccessful attempts where the distinction matters).

Tests name an algorithm identifier and a small set of counters that must have
been exercised by a targeted CFG. They reject missing counters, unexpected
algorithm identifiers and nonzero fallback counts. They do not reconstruct
the allocator's own decision algorithm. Instrumentation is evidence, not a
proof: source-path audits and native/symbolic correctness remain necessary.

Each implementation provides `( cfg registers -- )` through the public kernel
`greedy-allocation-with-registers`, `backtracking-allocation-with-registers`, or
`chordal-allocation-with-registers`. Validation wraps the kernel in the normal
generic dispatcher so the original-SSA snapshot and final checker stay active.
The default compiler path does not consult a new override flag.
