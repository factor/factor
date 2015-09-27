! Copyright (C) 2008, 2010 Slava Pestov, Jorge Acereda Macia.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.files.temp io words alien kernel math.parser
alien.syntax io.launcher assocs arrays sequences namespaces make
system math io.encodings.ascii accessors tools.disassembler
tools.disassembler.private locals ;
IN: tools.disassembler.gdb

SINGLETON: gdb-disassembler

: in-file ( -- path ) "gdb-in.txt" temp-file ;

: out-file ( -- path ) "gdb-out.txt" temp-file ;

:: make-disassemble-cmd ( from to -- )
    in-file ascii [
        "attach " write
        (current-process) number>string print
        "x/" write to from - 4 / number>string write
        "i" write bl from number>string write
    ] with-file-writer ;

: run-gdb ( -- lines )
    <process>
        +closed+ >>stdin
        out-file >>stdout
        [ "gdb" , "-x" , in-file , "-batch" , ] { } make >>command
    try-process
    out-file ascii file-lines ;

M: gdb-disassembler disassemble*
    make-disassemble-cmd run-gdb ;

gdb-disassembler disassembler-backend set-global
