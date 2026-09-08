# ARM64 integer encoding audit — 2026-09-08

This pass fills baseline integer instruction gaps in `cpu.arm.64.assembler`
and audits their shared encoding paths. It preserves the ARM64/SIMD and other
workspace edits present at the start of the task.

## Additions

- Carry arithmetic: ADC, ADCS, SBC, SBCS, NGC, NGCS.
- Extract/rotate and bitfield aliases: EXTR, immediate ROR, BFI, BFXIL.
- Byte reversal: REV16, REV32 (X registers), REV (W or X registers).
- Conditional compare: CCMN and CCMP, both register and immediate operands.
- Multiply: MNEG, SMADDL, SMSUBL, UMADDL, UMSUBL, SMULLs, SMNEGL,
  UMULLs, UMNEGL. The `s` suffix distinguishes scalar SMULL/UMULL from
  the existing SIMD words.

These are 24 instruction names/forms, including aliases. No optional ISA
extension or new compiler lowering is needed to expose these assembler words.

## Corrections

- Extended-register ADDS/SUBS now interpret destination register 31 as ZR;
  ADD/SUB interpret it as SP. This fixes valid extended CMP/CMN aliases
  previously rejected by the shared helper, and rejects SP for flag-setting
  destinations and ZR for non-flag-setting destinations.
- Reject ROR in shifted ADD/SUB, where the shift selector is reserved.
- Validate raw bitfield immediate ranges and positive extract widths.
- Validate conditions, TBZ/TBNZ bit indices, and extended LSL amounts before
  they can produce reserved encodings or spill into neighboring fields.
- Canonicalize logical-immediate rotations modulo the repeated element width.
  The previous encodings used ignored upper rotation bits and were semantically
  valid; this normalization makes their bytes agree with Clang.

## Validation

- `check-encodings.py` independently assembles 9,747 cases with Clang's AArch64
  assembler, extracts the ELF `.text` bytes, and generates Factor comparisons.
  All match byte for byte. It exercises 69 assembler words, W/X widths, low/high
  registers and ZR/SP, register/immediate forms, boundary fields, all 6,636
  distinct logical-immediate masks across both widths, and conditional-branch
  and test-and-branch limits.
- 65 permanent byte regressions and 38 invalid-operand regressions added to
  `assembler-tests.factor` (in addition to the pre-existing tests). All
  invalid-operand tests now run inside a byte builder, preventing a missing
  builder context from producing a false positive. The suite passes with zero
  failures and zero compiler errors.
- Existing SIMD oracle: 2,055 cases match (`simd-encodings.log`).
- **Broader backend/runtime verification completed successfully.** All five
  suites passed after explicitly reloading SIMD intrinsics, the assembler,
  the ARM64 backend, and SIMD extensions from current source:
  `cpu.arm.64.assembler`, `cpu.arm.64`, `math.vectors.conversion`,
  `math.vectors.simd.extensions`, and `cpu.arm.64.features`.
  Final result: **0 test failures, 0 compiler errors, exit status 0**.
  Log: `backend-verified-fixed-tests.log`; runner: `suites.factor`.
- The first completed run found seven failures unrelated to the new integer
  encoding formulas: unsigned inputs to `%signed-pack-vector` used signed-input
  SQXTUN/SQXTUN2, and `>float-vector-rep` lacked uint-4/ulonglong-2 mappings in
  the portable fallback. Matching fixes landed concurrently in the shared
  workspace: unsigned packing now uses UQXTN/UQXTN2, and both unsigned float
  conversion mappings are present. This verification task preserved those
  edits and confirmed all seven existing regressions pass after source reload.
  The failing run is retained as `backend-verified-tests.log`.
- SHA-256 checks confirm the eight relevant implementation/test files were
  unchanged during the passing run (`verification-fixed-source-sha256.txt`).
- Earlier load-limited attempts remain in `backend-tests.log` and
  `backend-loaded-tests.log`; they are superseded by the completed run above.
- `git diff --check`: clean.

Reproduce from the repository root:

```sh
python3 reference/arm64-encodings-20260908/check-encodings.py
./factor -no-user-init reference/arm64-encodings-20260908/encodings.factor
./factor -no-user-init reference/arm64-encodings-20260908/suites-assembler.factor
./factor -no-user-init reference/arm64-encodings-20260908/suites.factor
./factor -no-user-init reference/neon-audit-20260908/encodings.factor
```

Reference inventory: [Arm A-profile A64 ISA, base instructions](https://developer.arm.com/documentation/ddi0602/2026-06/Base-Instructions/UDF--Permanently-undefined-).
The independent encoding oracle is the locally installed Clang assembler.

This is not complete A64 ISA coverage. Other families still absent include
exclusive/acquire-release and LSE atomics, barriers, scalar FP fused operations,
CRC/crypto, and SVE/SME. The audit does not claim exhaustive operand validation
for all existing load/store or SIMD forms. No image was saved or commit made.
