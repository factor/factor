! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Source-level additions needed before older seed images load FFI syntax.
USING: alien fry kernel parser sequences vocabs words ;
IN: bootstrap.compat

! Older seeds lack the CPU classes referenced by shared FFI code. Refresh
! system before loading that code while preserving the existing class words.
<<
{
    "mips.32" "mipsel.32" "mips.64" "mipsel.64" "m68k.32"
    "ppc.32" "ppc.64" "ppc.64le" "sparc.32" "sparc.64"
    "s390x" "alpha.64" "loongarch.64" "m88k.32" "sh3.32" "sh4.32" "sh3be.32" "sh4be.32"
} [ "system" lookup-word ] all? [
    "resource:core/system/system.factor" run-file
] unless
>>

! Shared FFI code can be newer than the architecture declarations in a seed.
! Refresh before alien.c-types and varargs consume the added ABI predicate.
<<
"aapcs64-va-list-platform?" "cpu.architecture" lookup-word [
    "resource:basis/cpu/architecture/architecture.factor" run-file
] unless
>>

! This is a compile-only word, not a VM primitive. Keep its declaration in
! sync with core/alien/alien.factor. Preserve the existing word and inference
! properties when bootstrapping from a seed that already contains it.
<<
"alien-callback-varargs" "alien" lookup-word [
    "alien-callback-varargs" "alien" create-word
    dup '[ _ callsite-not-compiled ]
    ( return named-parameters abi quot -- alien ) define-declared
] unless
>>
