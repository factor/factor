# Linux issue review

Reviewed the 27 open issues labeled `linux` on 2026-09-08 against
`master-candidate` at `c83f2f171bbbd250fecd5b70b2ec605c5f9da075`.
Remote branch tips matched the local branches. `master` at `b21f5d1611`
is an ancestor: candidate is 194 commits ahead, zero behind, with 500 changed
files (14,468 insertions and 1,749 deletions).

## Changes in this working tree

| Issue | Change | Validation |
| --- | --- | --- |
| [#902](https://github.com/factor/factor/issues/902) mouse button representation | Both GTK2 and X11 polling return five booleans in X11 button order, excluding modifier bits. Correct the `XQueryPointer` output buffers to use `Window` and `uint`. Remove GML's integer workaround. | Mask and button transition tests; real XTest press/release events for all five buttons through both backends under Xvfb. |
| [#180](https://github.com/factor/factor/issues/180) keypad Enter | The listener submits input for keypad Enter as well as Return. Shift with either key continues to insert a newline. | Exercise keypad Enter through gesture dispatch for incomplete and complete quotations, plus both shifted gestures. |
| [#2824](https://github.com/factor/factor/issues/2824) demo resizing | Boids movement, added birds, and randomization use allocated gadget dimensions. Bubble chamber centers, bounds, mirrored positions, and mouse calculations use allocated dimensions. Keep the existing default-size simulation API. | Deterministic grow/shrink and bounds tests; native GTK3 window resizing at 1× and 2× display scale for both demos. The report's separate vague Papier observation remains unverified. |

The fixes address simulation bounds directly. Native GTK3 allocation delivered
the requested sizes in these checks without backend changes.

## Existing fixes and remaining reports

This is a triage inventory, not a claim that every report has been reproduced.
No GitHub issues were modified, commented on, or closed.

| Issue(s) | Disposition |
| --- | --- |
| [#2473](https://github.com/factor/factor/issues/2473) Ubuntu library loading | Candidate commit `0e95fc5573` already registers versioned GTK runtime SONAMEs. See the earlier Linux validation record. |
| [#1718](https://github.com/factor/factor/issues/1718) `/proc` PID reuse race | Candidate commit `95dbbb5a89` anchors reads to an open directory. |
| [#2594](https://github.com/factor/factor/issues/2594), [#1890](https://github.com/factor/factor/issues/1890) Linux32 NaNs | Candidate already preserves NaN bits and restores the disabled regressions. This pass uses Linux x86-64; native Linux32 confirmation remains separate. |
| [#2379](https://github.com/factor/factor/issues/2379) control characters | Candidate commit `4a5068d53a` addresses the reported Cocoa input path. |
| [#89](https://github.com/factor/factor/issues/89) incorrect GTK bindings | Candidate fixes GdkPixbuf buffer handling and preserves manually corrected bindings across GIR reloads. The broader request to remove all workarounds is not completed. |
| [#2528](https://github.com/factor/factor/issues/2528) raylib | The issue comments identify an earlier crash fix; current code uses `RayCollision.point`. Camera/mouse behavior still needs live raylib reproduction. |
| [#2264](https://github.com/factor/factor/issues/2264) build library detection | `build.sh` still checks linker names with `-l`; runtime-only installations can produce misleading diagnostics. Not changed in this pass. |
| [#2171](https://github.com/factor/factor/issues/2171), [#2180](https://github.com/factor/factor/issues/2180), [#1099](https://github.com/factor/factor/issues/1099) musl/NixOS/library finder | Require platform-specific follow-up; Linux finder still invokes `/sbin/ldconfig`. No claim of musl or NixOS support validation. |
| [#2270](https://github.com/factor/factor/issues/2270) native MSYS2 | Separate porting work; this environment does not reproduce MSYS2. |
| [#1889](https://github.com/factor/factor/issues/1889) GC metadata | Intermittent Linux32 report; not reproduced here. |
| [#1911](https://github.com/factor/factor/issues/1911), [#1884](https://github.com/factor/factor/issues/1884) GPU rendering | Need the reported graphics hardware/driver reproduction. Xvfb checks do not validate Intel hardware rendering. |
| [#1679](https://github.com/factor/factor/issues/1679), [#901](https://github.com/factor/factor/issues/901), [#755](https://github.com/factor/factor/issues/755) window offset, capture, clipped text | Separate interactive reproductions remain. Correct mouse-state representation alone does not establish that pointer capture is fixed. |
| [#1669](https://github.com/factor/factor/issues/1669), [#1482](https://github.com/factor/factor/issues/1482), [#1129](https://github.com/factor/factor/issues/1129) ping, locale encoding, FIFOs | Untouched; these need dedicated protocol, locale, and I/O behavior tests. |
| [#1951](https://github.com/factor/factor/issues/1951), [#1249](https://github.com/factor/factor/issues/1249), [#606](https://github.com/factor/factor/issues/606) notifications, file picker, text cache | Feature/API or caching work outside this bug-fix batch. |

## Validation

The VM and runtime image were copied from the matching native Linux validation
checkout described in [the prior report](../linux-validation-df67b9a37b/README.md).
There are no VM or core changes in this batch. Changed preloaded vocabularies
are refreshed before testing; missing imports are not automatically supplied.

`targeted.factor` runs the game input, boids, bubble chamber, and listener tests,
then help lint and code lint for changed vocabularies, including GML. Results:
148 test assertions, zero test failures, zero compiler errors. Final help lint
has zero failures (the new simulation documentation was corrected and rechecked
separately in `logs/linux-issues/help-final.log`). Code lint
prints existing duplication suggestions. This is targeted validation, not a
new full `load-all`/`test-all` run.

Reproduction from the repository root, with a matching VM/image:

```sh
mkdir -p logs/linux-issues/tmp
# Supply GTK2 runtime libraries on LD_LIBRARY_PATH if absent on the host.
xvfb-run -a ./factor -q -no-user-init reference/linux-issues-20260908/targeted.factor
xvfb-run -a ./factor -q -no-user-init reference/linux-issues-20260908/mouse.factor
xvfb-run -a -s '-screen 0 2400x1800x24' ./factor -q -no-user-init reference/linux-issues-20260908/resize.factor
GDK_SCALE=2 xvfb-run -a -s '-screen 0 3000x2200x24' ./factor -q -no-user-init reference/linux-issues-20260908/resize.factor
```

Local logs are retained in the ignored `logs/linux-issues/` directory. GTK2
runtime libraries were copied into its private `libraries/` directory; no
system packages or existing displays were changed. All Xvfb instances are
scoped to `xvfb-run` and exit with their test process.
