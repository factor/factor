# Open `floats` issues reviewed on 2026-09-08

Source inventory: `open-floats-issues.json`; issue bodies and comments are also
saved individually as `issue-N.json`. This is a local implementation audit.
No GitHub issues were closed and no comments were posted.

The host is ARM64 macOS; x64 execution is through Rosetta. Native Windows,
Linux32, and Intel-hardware validation is outside the evidence from this machine.

| Issue | Disposition and implementation | Evidence / limit |
| --- | --- | --- |
| [#3138](https://github.com/factor/factor/issues/3138) UCRT `pow` underflow | `b2a4f18cb0`: Windows wrapper reports underflow/inexact when a finite, nonzero base raised to a finite power rounds to zero. Excludes exact zeros involving zero or infinite operands and does not force flags for exact subnormals. Removed the test workaround. | Correction helper passes ARM64 and x64, including exclusions. UCRT itself has not been executed here. |
| [#2594](https://github.com/factor/factor/issues/2594) signaling-NaN printing | `1bf4fccf1d`, `39404f24d2`: transport boxed double bits without loading them through floating-point conversion; restore the Linux32-disabled printing regression. | Prettyprinter suite passes ARM64 and x64. Native Linux32 remains to be checked. |
| [#2378](https://github.com/factor/factor/issues/2378) shaped arrays beyond two dimensions | `734552bd4a`: recursively infer uniform child dimensions and flatten the shape; preserve ragged-array rejection. | 3D/4D, empty dimensions, and ragged regressions pass ARM64 and x64. |
| [#2182](https://github.com/factor/factor/issues/2182) float32 signaling-NaN round trips | `1bf4fccf1d`: preserve sign, payload, and signaling/quiet bit using integer NaN transport in C++ and Zig; use hardware conversion for finite values. A truncated, nonzero double payload remains a NaN. | Every signed float32 NaN encoding checked in C++ ARM64/x64 and Zig; Factor compiled and primitive paths pass. |
| [#1890](https://github.com/factor/factor/issues/1890) truncate signaling-NaN flags | `1bf4fccf1d`, `39404f24d2`: prevent premature quieting during bit transport and restore the disabled exception regression. `truncate` already performs arithmetic on special inputs to report invalid. | Restored test and math.functions suite pass ARM64/x64. Native Linux32/VMware remains to be checked. |
| [#1598](https://github.com/factor/factor/issues/1598) ordered/unordered primitive aliases | `7af529d080`: distinct C++ and Zig primitives and bootstrap bindings. Ordered comparisons report invalid for any NaN; unordered comparisons do so only for signaling NaNs. | Dynamic primitive flag tests pass C++ ARM64/x64 and Zig x64. Fresh final images incorporate the bindings without manual rebinding. |
| [#1560](https://github.com/factor/factor/issues/1560) parse-float benchmark coverage | `41478aa0d1`: sample the full finite binary64 bit range and require exact bit round trips. | 100,000 unit-range samples and 100,000 samples from the full finite bit range pass on each architecture. |
| [#1556](https://github.com/factor/factor/issues/1556) literal selection conversion | `14906289a4`, `759981327a`: fold exact `fixnum>float` conversions across literal selections. Follow copies and every phi output; reject shared integer uses, nonliteral inputs, and potentially inexact conversions. Run before modular tree splicing. | Both issue examples eliminate the conversion. Compiled outcomes, shared/duplicated phi outputs, and compiler tree suites pass ARM64/x64; refreshed library/compiler integration also passes. |
| [#1313](https://github.com/factor/factor/issues/1313) slow range membership | `ccf77f588b`: make `member?` generic and specialize integer ranges with arithmetic membership instead of enumeration. Float ranges retain sequence semantics. | Huge ascending/descending ranges, zero step, empty ranges, and mixed float/integer equality pass ARM64/x64. |
| [#709](https://github.com/factor/factor/issues/709) normal-random algorithm | Already implemented: `basis/random/random.factor` uses the proposed Box–Muller transform. | Source inspection; no new algorithm was substituted without a demonstrated performance need. |
| [#528](https://github.com/factor/factor/issues/528) NaN equality documentation | `bb60999474`: distinguish numeric unordered comparisons from object identity and equality. | Focused help lint passes. Broader comment proposals for a new total NaN ordering were not silently adopted. |
| [#515](https://github.com/factor/factor/issues/515) indeterminate powers | `b19d446316`: consistent NaN results for indeterminate real powers, with documentation. Also fix `2.0 0 ^`, which incorrectly returned its base. | Edge cases and math.functions suite pass ARM64/x64. |
| [#510](https://github.com/factor/factor/issues/510) signed zero versus integer equality | `bb60999474`: explain type-sensitive object `=` and promoting numeric `number=`. | Documented intended behavior; no equality contract was changed. |
| [#507](https://github.com/factor/factor/issues/507) complex literals | `16f4564a08`, `cd0cb05eec`: accept `a+bj`, `a-bj`, and `bj`, including signed exponents, rational components, and implicit unit coefficients. Preserve `C{ a b }`; bare `j` remains a word. Rectangular syntax wins the mixed-ratio ambiguity (`1+1/2j` means `C{ 1 1/2 }`). | String conversion and actual source literal tests pass ARM64/x64; malformed input and existing parser regressions pass. |
| [#498](https://github.com/factor/factor/issues/498) native decimal conversion | Native Factor parsing and Dragonbox formatting already exist. `822b497caa` fixes missing cache powers and an incorrect open-interval rounding condition. | Before: 4 cache failures and 8 one-ULP formatting errors. After: all 16,138 exponent-boundary/random cases round-trip exactly on ARM64/x64, plus the expanded random benchmark. |

## Decimal conversion choice

The existing implementation is Dragonbox, so repairing it was a smaller,
reviewable change than replacing it with Ryu. The reference header and commit
are saved as `dragonbox-reference.h` and `dragonbox-reference-commit.txt`.
The boundary corpus spans every finite binary64 exponent and multiple mantissa
boundaries, with an additional fixed-seed random sample. Exact bit equality
checks signed zero as well as finite magnitudes. NaN encoding preservation is
validated separately because decimal NaN spelling is not a payload transport.

See `RESULTS.md` for complete final load/test outcomes and platform limitations.
