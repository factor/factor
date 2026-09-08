! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Upgrade old ARM64 seed images without changing their ordinary callback ABI.
USING: assocs bootstrap.image.private hashtables kernel kernel.private math
namespaces parser sequences system ;
IN: bootstrap.compat.arm64

cpu arm.64? CALLBACK-STUB special-object length 3 < and [
    [
        H{ } clone special-objects set
        H{ } clone sub-primitives set
        os windows?
        [ "resource:basis/bootstrap/assembler/arm.windows.factor" ]
        [ "resource:basis/bootstrap/assembler/arm.unix.factor" ] if run-file
        "resource:basis/bootstrap/assembler/arm.64.factor" run-file

        ! Existing callback heap entries use the old relocation table during
        ! GC. Preserve both ordinary-template items, even if newer assembler
        ! sources have changed the ordinary entry sequence since the seed.
        CALLBACK-STUB special-object
        CALLBACK-STUB special-objects get at third suffix
        CALLBACK-STUB set-special-object
    ] with-scope
] when
