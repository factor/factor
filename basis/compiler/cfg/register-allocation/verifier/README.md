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
Transport instructions must preserve the original value's register class
and full width. Original derived-pointer/base pairs must have matching final
slots, and unrooted copies of moving pointers become invalid at collection.
Extra tagged roots must contain a proven tagged value, including synthetic
false bases, rather than an uninitialized slot or arbitrary integer.
Allocation statistics remain in the caller's namespace.
The optional rematerialization vocabulary installs its provenance observer
automatically when both vocabularies are loaded. GC maps must also keep
derived slots distinct from tagged root slots: the collector temporarily
subtracts bases from derived values before tracing roots.

This is a value-flow checker, not a proof of the compiler or target emitter.
It trusts original instruction semantics and representation selection, and
does not validate every target-specific operand restriction, emitted machine
encoding, or numeric arithmetic result. Existing interval legality checking
remains necessary. Derived-pointer base discovery uses the compiler's original
SSA liveness analysis; companion derived-base relationships added later are
outside that original specification. Synthetic false bases receive a distinct
known-tagged token. The model tracks full register contents by register class
and width, and spill contents by byte.

The opt-in checker uses whole-CFG fixed-point iteration and symbolic sets;
its cost is intentionally outside the default compiler path. Generated and
adversarial tests exercise finite cases; passing them is not a proof of
allocator correctness.
