! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: bootstrap.arm

DEFER: stack-reg

: jit-save-tib ( -- ) ;
: jit-restore-tib ( -- ) ;
: jit-update-tib ( ctx-reg -- ) drop ;
: jit-install-seh ( -- ) ; ! stack-reg bootstrap-cell ADD ;
: jit-update-seh ( ctx-reg -- ) drop ;
