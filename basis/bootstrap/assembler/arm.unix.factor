! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: bootstrap.assembler.arm

DEFER: stack-reg

! these are all windows-only functions.
! NO-OPs appear to be correct on UNIX. 
: jit-save-tib ( -- ) ;
: jit-restore-tib ( -- ) ;
: jit-update-tib ( ctx-reg -- ) drop ;
: jit-install-seh ( -- ) ; ! stack-reg bootstrap-cell ADD ;
: jit-update-seh ( ctx-reg -- ) drop ;
