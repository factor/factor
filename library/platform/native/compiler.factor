IN: compiler
USE: math
USE: stack
USE: lists
USE: combinators
USE: words
USE: namespaces
USE: unparser
USE: errors
USE: strings
USE: logic
USE: kernel

: DATASTACK
    #! A pointer to a pointer to the datastack top.
    11 getenv ;

: EAX 0 ;
: ECX 1 ;
: EDX 2 ;
: EBX 3 ;
: ESP 4 ;
: EBP 5 ;
: ESI 6 ;
: EDI 7 ;

: I>R ( imm reg -- )
    #! MOV <imm> TO <reg>
    HEX: a1 + compile-byte  compile-cell ;

: I>[R] ( imm reg -- )
    #! MOV <imm> TO ADDRESS <reg>
    HEX: c7 compile-byte  compile-byte  compile-cell ;

: I+[I] ( imm addr -- )
    #! ADD <imm> TO ADDRESS <addr>
    HEX: 81 compile-byte
    HEX: 05 compile-byte
    compile-cell
    compile-cell ;

: LITERAL ( cell -- )
    #! Push literal on data stack.
    DATASTACK EAX I>R  EAX I>[R] 4 DATASTACK I+[I] ;

: (JMP) ( xt opcode -- )
    #! JMP, CALL insn is 5 bytes long
    #! addr is relative to *after* insn
    compile-byte  compile-offset 4 + - compile-cell ;

: JMP HEX: e9 (JMP) ;
: CALL HEX: e8 (JMP) ;
: RET HEX: c3 compile-byte ;

: compile-word ( word -- )
    #! Compile a JMP at the end (tail call optimization)
    word-xt "compile-last" get [ JMP ] [ CALL ] ifte ;

: compile-fixnum ( n -- )
    3 shift 7 bitnot bitand  LITERAL ;

: compile-atom ( obj -- )
    [
        [ fixnum? ] [ compile-fixnum ]
        [ word? ] [ compile-word ]
        [ drop t ] [ "Cannot compile " swap unparse cat2 throw ]
    ] cond ;

: compile-loop ( quot -- )
    dup [
        unswons
        over not "compile-last" set
        compile-atom
        compile-loop
    ] [
        drop RET
    ] ifte ;

: compile-quot ( quot -- xt )
    [
        "compile-last" off
        compile-offset swap compile-loop
    ] with-scope ;

: compile ( word -- )
    intern dup word-parameter compile-quot swap set-word-xt ;

: call-xt ( xt -- )
    #! For testing.
    0 f f <word> [ set-word-xt ] keep execute ;
