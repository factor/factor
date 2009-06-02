! Copyright (C) 2008 Slava Pestov, Jorge Acereda Macia.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.files.temp io words alien kernel math.parser
alien.syntax io.launcher assocs arrays sequences
namespaces make system math io.encodings.ascii
accessors tools.disassembler ;
IN: tools.disassembler.gdb

SINGLETON: gdb-disassembler

: in-file ( -- path ) "gdb-in.txt" temp-file ;

: out-file ( -- path ) "gdb-out.txt" temp-file ;

: make-disassemble-cmd ( from to -- )
    in-file ascii [
        "attach " write
        current-process-handle number>string print
        "disassemble " write
        [ number>string write bl ] bi@
    ] with-file-writer ;

: gdb-binary ( -- string ) "gdb" ;

: run-gdb ( -- lines )
    <process>
        +closed+ >>stdin
        out-file >>stdout
        [ gdb-binary , "-x" , in-file , "-batch" , ] { } make >>command
    try-process
    out-file ascii file-lines ;

M: gdb-disassembler disassemble*
    make-disassemble-cmd run-gdb ;

gdb-disassembler disassembler-backend set-global
