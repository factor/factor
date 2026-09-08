# ARM64 instruction selection and assembler gap audit

This is a bounded extension of the baseline A64 backend, not complete Arm ISA support.

## Assembler coverage

Added single-register baseline acquire/release and exclusive accesses, in 8-, 16-, 32-, and 64-bit forms: LDAR/STLR, LDXR/LDAXR, STXR/STLXR and their B/H forms. Addresses are bare X registers or SP, with no offset/writeback. Status operands are W registers. Constrained-unpredictable status/data and status/non-SP-base overlaps are rejected, matching Clang. Added DMB/DSB four-bit options, default ISB/CLREX, and single/double scalar FMADD/FMSUB/FNMADD/FNMSUB.

`check-encodings.py` independently assembles the source spellings with Clang targeting aarch64-linux-gnu, extracts ELF .text bytes, and creates Factor assertions. Expected words are never constructed from Factor's encoding constants. Persistent assembler unit tests contain selected oracle bytes and negative operands. The artifact oracle covers ordinary, high, zero, SP, and aliased operands and all barrier options.

These words expose instruction assembly; they do not add language-level atomics or change the VM memory model. Atomic pair exclusive loads/stores, LSE atomics (CAS/CASP, SWP, LDADD/LDCLR/LDEOR/LDSET/SMAX/SMIN/UMAX/UMIN and acquire/release variants), RCpc variants, CRC32, AES/SHA/PMULL and other optional crypto families remain outside this patch. Those need actual API/compiler consumers, architecture feature checks and semantics/runtime validation. The existing baseline VM remains the authority for language synchronization.

Scalar fused floating-point operations round once, unlike a separate multiply and add. The CFG currently has a vector FMA operation but no scalar FMA operation. This patch does not silently contract ordinary scalar arithmetic or add an unsupported scalar feature flag.

## Compiler representation limits

`math.bitwise:bitroll-32`, `bitroll-64`, and `endian.private:byte-reverse` currently expand into general-integer shifts, masks, and ORs. Integer values can be bignums; intermediate truncation/tagging semantics matter. ROR/EXTR/REV recognition therefore requires a carefully proven expression matcher or a dedicated fixed-width conversion/rotation IR, not merely changing one existing backend method. Scalar widening multiply and conditional compare likewise have no directly corresponding CFG operation. They remain assembler facilities rather than claimed compiler support.

## SVE/SVE2 and SME

The current backend has fixed 128-bit V registers and fixed-size vector representations; vector length, load/store size, lane indexing, register class, spills and ABI assignment all assume that model. SVE adds scalable Z registers and separate predicate registers, with vector lengths in 128-bit increments from 128 to 2048 bits. A supported SVE backend needs scalable representations, predicate/mask semantics (including inactive-lane behavior), dynamic vector-length-aware allocation and spilling, instruction constraints, ABI save/restore and calls, feature discovery, and loop/tail lowering. Adding assembler names and advertising the existing NEON reps would not implement this.

SME additionally introduces streaming mode, a separately controlled streaming vector length, and ZA matrix state. Required work includes mode/state effects in the CFG, preventing illegal motion across mode transitions and calls, streaming-compatible function interfaces, ZA ownership/preservation and lazy-save ABI handling, platform signal/thread/context integration, and matrix operation/shape representations. This is a larger separate backend and runtime project. No SVE/SME support is enabled here.

Primary references:
- [Arm A64 instruction reference](https://developer.arm.com/documentation/ddi0602/latest/)
- [Arm scalar floating-point instruction guide](https://developer.arm.com/documentation/100069/0605/A64-Floating-point-Instructions)
- [Arm Introduction to SVE](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/SVE%20programmers%20guide/102476_0001_00_en_introduction-to-sve.pdf)
- [Arm SME introduction](https://developer.arm.com/community/arm-community-blogs/b/architectures-and-processors-blog/posts/arm-scalable-matrix-extension-introduction)
- [Arm AAPCS64, scalable types and SME interfaces](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst)
- [Apple XNU SME context support](https://github.com/apple-oss-distributions/xnu/blob/main/doc/arm/sme.md)
