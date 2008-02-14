USING: io.files io words alien kernel math.parser alien.syntax
io.launcher system assocs arrays ;
IN: tools.disassembler

GENERIC: make-disassemble-cmd ( word -- file )

M: word make-disassemble-cmd
    word-xt 2array make-disassemble-cmd ;

M: pair make-disassemble-cmd
    "gdb.txt" resource-path [
        [
            "disassemble " write
            [ number>string write bl ] each
        ] with-file-out
    ] keep ;

: run-gdb ( cmds -- output )
    [
        +closed+ +stdin+ set
        [
            "gdb" ,
            vm ,
            getpid number>string ,
            "-x" , ,
            "-batch" ,
        ] { } make +arguments+ set
    ] { } make-assoc <process-stream> contents ;

: disassemble ( word -- )
    make-disassemble-cmd run-gdb write ;
