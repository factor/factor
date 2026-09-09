# Existing boot-image compatibility

The new callback entry is a compile-only Factor word, not a new VM primitive.
Older compatible version-5 seed images have neither that word nor the third
callback machine-code template. Source bootstrap upgrades both without requiring
a seed republished specifically for variadic callbacks. The separate official
version-4 seed limitation below still applies to default net-bootstrap CI.

`bootstrap.compat` loads before stage2's command-line/compiler dependencies. It
creates the missing word with the same body and declared effect as core/alien;
when the word already exists, its identity, definition, and inference properties
are untouched. This helper depends only on core vocabularies, avoiding the two
FFI source dependency cycles discovered during Linux bootstrap.

After loading components, stage2 requires `bootstrap.compat.arm64` on ARM64.
When needed, it generates current assembler templates in a temporary namespace
scope and appends only the variadic template to the existing callback special
object. The existing first two items remain intact because live ordinary
callback stubs still use their relocation offsets during GC. Other architectures
and images already containing the variadic template are unchanged.

## Verification

`upgrade.factor` runs against the older verified image. Eight checks verify the
missing word/template baseline, declared effect, retained ordinary template,
word identity/definition/properties on reload, and idempotent template upgrade.
`upgrade.log` records the passing run. The script intentionally requires an old
image rather than silently accepting a pre-upgraded one.

`capture.factor` uses the independent C caller from
`reference/arm64-varargs-entry-20260908/capture.c`. Allocation first fails with
an old template. Loading the compatibility vocabulary then allows two successful
calls checking all eight GP and eight FP captures after compacting GC.
`capture.log` records that fail-then-pass transition.

Commands from the entry worktree:

```sh
clang -shared -o /tmp/arm64-varargs-entry-capture.dylib reference/arm64-varargs-entry-20260908/capture.c
./factor -i=/Users/erg/factor.worktrees/arm64-gaps-integration/verified.image -resource-path=/Users/erg/factor.worktrees/arm64-varargs-entry reference/arm64-varargs-bootstrap-compat-20260908/upgrade.factor
./factor -i=/Users/erg/factor.worktrees/arm64-gaps-integration/verified.image -resource-path=/Users/erg/factor.worktrees/arm64-varargs-entry reference/arm64-varargs-bootstrap-compat-20260908/capture.factor
```

A full native macOS stage2 run from the older `boot.unix-arm.64.image` passed
with exit 0 and saved `/tmp/factor-varargs-old-seed.image`. It used current root
source through a temporary overlay containing the compatibility patch, with
`-include="math compiler threads io tools"`. `full-bootstrap.log` records both
compatibility vocabularies loading and successful image creation. No root files
or externally published seed images were changed.

Restarting that image passed 40 unit checks plus 2 expected-failure checks with
zero compiler errors (`full-bootstrap-tests.log`). These cover the new intrinsic
and template, incoming/outgoing variadic C calls, native `va_list`, formatting,
and positively available Clang half/BF16 callback controls. This run predates
the final additional half-union fixtures; those remain part of root integration
validation rather than this bootstrap compatibility proof.

## Separate official seed version blocker

On 2026-09-08, the exact default fallback artifact
`https://downloads.factorcode.org/images/master/boot.unix-arm.64.image`
(SHA-256 `76a09ef2d7c762ca38270cabc050f213f0b861e382631cd6ee80bde887b6b495`)
contained image version 4. The current repository VM requires version 5, a
preexisting arithmetic/bootstrap compatibility change. It rejects this official
seed before any Factor source can run. `official-v4-seed.log` records exit 134
and `Bad image: version number check failed: 0x4`. Thus the successful version-5
seed proof above does not establish default official-download CI success.

A matching released stage1 host was tested in a new isolated remote directory:
`https://downloads.factorcode.org/releases/0.101/factor-linux-x86-64-0.101.tar.gz`,
SHA-256 `9f971e935414c0d46d9090632464d66994ee797bacc91cc8b739db3b0857a25a`.
Its paired VM/image reports Factor 0.101, commit `a56e6390e8`, Dec 8 2025.
Loading the current image writer and architecture source into that host exposes
additional preexisting host/source incompatibilities: new half/BF16
representations, `method-for-class-cache`, and `PIC-MISS-RESUME-WORD`. The bounded
experiment did not establish a safe released-host seed-generation helper.
`released-host-stage1.log` records the final missing special-object constant.

CI needs a compatible version-5 seed artifact or a separately validated stage1
host upgrade that writes new seeds. No image header was patched and the VM
version check remains intact. This issue is distinct from the variadic callback
word/template compatibility implemented and tested here.
