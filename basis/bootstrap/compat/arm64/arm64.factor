! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Keep the current-seed path independent of image building and the compiler.
USING: kernel kernel.private math parser sequences system ;
IN: bootstrap.compat.arm64

: needs-arm64-callback-upgrade? ( -- ? )
    cpu arm.64? [ CALLBACK-STUB special-object length 3 < ] [ f ] if ;

: upgrade-arm64-callbacks ( -- )
    needs-arm64-callback-upgrade? [
        ! Parse the assembler/image dependencies only on the legacy path.
        "resource:basis/bootstrap/compat/arm64/legacy.factor" run-file
    ] when ;

upgrade-arm64-callbacks
