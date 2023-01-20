! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.stacks compiler.constants cpu.architecture kernel ;
IN: compiler.cfg.intrinsics.strings

: (string-nth) ( n string -- base offset rep c-type )
    ^^tagged>integer swap ^^add string-offset int-rep uchar ; inline

: emit-string-nth-fast ( -- )
    2inputs (string-nth) ^^load-memory-imm ds-push ;

: emit-set-string-nth-fast ( -- )
    3inputs (string-nth) ##store-memory-imm, ;
