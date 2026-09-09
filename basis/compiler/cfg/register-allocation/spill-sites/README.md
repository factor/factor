# Loop-aware backtracking spill placement

`backtracking-loop-spills?` enables an experimental backtracking policy. It
is off by default and does not affect linear scan, greedy, or chordal.
The original backtracking median split and unweighted density remain the
option-off behavior.

The policy uses bounded static loop weights (`8^min(depth,3)`) for three
related decisions:

* Bundle use density is computed once when a bundle is constructed, keeping
  hot fragments competitive during eviction.
* Among the middle half of adjacent-use gaps, a strictly cheaper loop-depth
  transition can replace the median. The score covers the actual last-use
  store and next-use reload sites. Equal-cost candidates prefer a balanced
  split. This does not assume that a CFG boundary automatically hoists a
  reload: the shared splitter trims fragments to their actual uses.
* An interval with exactly one cold `int-rep` definition, whose first read
  is hot, can place its first spill immediately after that definition. A
  subsequent fragment that reloads its same private spill slot, has no
  definitions, and preserves the representation does not store that value
  back again **only after an actual cold store has been established**. The
  final allocated intervals must contain the defining fragment, its real
  slot store immediately after the definition, and a following instruction
  in that same cold block. Eligibility or a requested split is insufficient:
  mandatory clobber splitting can otherwise leave the store in a bypassed
  hot body. The definition count comes from the original unsplit interval,
  not just equality of coalesced leader IDs or physical registers.

The last transformation rejects ABI memory operands and entire CFGs with
any GC-map instruction. Its slot/representation equality and absence of
fragment definitions are checked before assignment. The defining fragment
always retains its store. Original instructions and all required operand
uses remain present; edge resolution and clobber splitting are unchanged.

Each ordinary split leaves at least a quarter of the uses on either side.
The exceptional one-definition cut can happen only once for an original
interval; all descendants without definitions return to balanced splitting.
Existing one-use trimming and infinite-weight minimal fragments preserve
termination and mandatory-register coverage.

Tests cover cooler-site choice, multiple definitions, ABI uses, GC exclusion,
slot and representation mismatches, and actual native execution through
zero, one, and multiple loop iterations. Native fixtures run interval,
numbering, and final value-flow checks. The runtime input creates all live
values, and every arithmetic result contributes to the returned checksum.
The previous backtracking regression suite also passes.
Additional native fixtures place an unrelated non-GC clobber between hot
reads and exercise the zero-iteration bypass, preventing read-only fragments
entered in their middle from losing a still-required initializing store.

The six-fixture ARM64 sweep and alternating runtime evidence are in
`reference/allocator-spill-sites-20260908`. Uniform 40-value pressure reduced
hot-loop spill/reload instructions from 558 to 280 and code from 5920 to
4336 bytes, with a spill-area tradeoff of 312 to 328 bytes. The recorded
runtime median improved 16.1%, and retired instructions fell 31.4%.
These are focused synthetic results, not a representative bootstrap claim.

Placement scoring alone slightly regressed the uniform-pressure fixture;
the enabled policy includes weighted density and the proven cold-store
placement/elimination described above. Broader application and bootstrap
measurements are required before considering a default change.
