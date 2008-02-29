! Copyright (C) 2008 Slava Pestov, Jorge Acereda Macia.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io words alien kernel math.parser alien.syntax
io.launcher system assocs arrays sequences namespaces qualified
system math generator.fixup io.encodings.ascii ;
IN: tools.disassembler

: in-file "gdb-in.txt" temp-file ;

: out-file "gdb-out.txt" temp-file ;

GENERIC: make-disassemble-cmd ( obj -- )

M: word make-disassemble-cmd
    word-xt code-format - 2array make-disassemble-cmd ;

M: pair make-disassemble-cmd
    in-file ascii [
        "attach " write
        current-process-handle number>string print
        "disassemble " write
        [ number>string write bl ] each
    ] with-file-writer ;

: run-gdb ( -- lines )
    [
        +closed+ +stdin+ set
        out-file +stdout+ set
        [ "gdb" , "-x" , in-file , "-batch" , ] { } make +arguments+ set
    ] { } make-assoc try-process
    out-file ascii file-lines ;

: tabs>spaces ( str -- str' )
    { { CHAR: \t CHAR: \s } } substitute ;

: disassemble ( word -- )
    make-disassemble-cmd run-gdb
    [ tabs>spaces ] map [ print ] each ;
