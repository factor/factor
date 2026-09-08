! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Source-level additions needed before older seed images load FFI syntax.
USING: alien fry kernel vocabs words ;
IN: bootstrap.compat

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
