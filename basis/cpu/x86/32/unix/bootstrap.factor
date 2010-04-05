! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.x86.assembler cpu.x86.assembler.operands kernel
layouts parser sequences ;
IN: bootstrap.x86

: jit-save-tib ( -- ) ;
: jit-restore-tib ( -- ) ;
: jit-update-tib ( ctx-reg -- ) drop ;
: jit-install-seh ( -- ) ESP bootstrap-cell ADD ;
: jit-update-seh ( ctx-reg -- ) drop ;

<< "vocab:cpu/x86/32/bootstrap.factor" parse-file suffix! >>
call
