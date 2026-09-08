# Final allocation value-flow checking

Load `compiler.cfg.register-allocation.verifier` and set
`compiler.cfg.linear-scan.allocation.state:check-allocation?` to true.
`value-flow-verifier-enabled?` reports whether the final checker is installed.
The ordinary flag alone continues to enable the existing interval checks;
it does not load this optional vocabulary. The default allocator and GVN
settings are unchanged.

The generic `allocate-registers` entry point snapshots original SSA operands,
copies, phi edges and GC roots before allocation. After assignment and edge
resolution, the checker interprets physical register and spill-byte contents.
Original definitions introduce symbolic values; copies, spills and reloads
transport them; clobbers and temporaries destroy them. Parallel phi semantics
rename incoming values on the corresponding original edge, including edges
split by CSSA and the resolver. A fixed point intersects the values guaranteed
at joins and back edges, and only then checks every surviving original use.

Checks include ABI operands residing in spill slots, tagged GC root slots,
temporary overlap with operands, partial spill overwrites, missing original
instructions, and rematerialization provenance with an immutable integer
literal. Constant rematerialization preserves existing copies of that value.
Allocation statistics remain in the caller's namespace.

This is a value-flow checker, not a proof of the compiler or target emitter.
It trusts original instruction semantics and representation selection, and
does not validate every target-specific operand restriction, emitted machine
encoding, or numeric arithmetic result. Existing interval legality checking
remains necessary. Derived-pointer base discovery uses the compiler's original
SSA liveness analysis; synthetic companion bases added later are not original
values and do not receive provenance tokens. The model tracks full register
contents by register class, and spill contents by byte.

The opt-in checker uses whole-CFG fixed-point iteration and symbolic sets;
its cost is intentionally outside the default compiler path. Generated and
adversarial tests exercise finite cases; passing them is not a proof of
allocator correctness.
