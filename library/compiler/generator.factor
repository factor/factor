! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler inference errors kernel lists math namespaces
strings words vectors ;

: generate-node ( [[ op params ]] -- )
    #! Generate machine code for a node.
    unswons dup "generator" word-prop [
        call
    ] [
        "No generator" throw
    ] ?ifte ;

: generate-code ( word linear -- length )
    compiled-offset >r
    compile-aligned
    swap save-xt
    [ generate-node ] each
    compile-aligned
    compiled-offset r> - ;

: generate-reloc ( -- length )
    relocation-table get
    dup [ compile-cell ] vector-each
    vector-length cell * ;

: (generate) ( word linear -- )
    #! Compile a word definition from linear IR.
    100 <vector> relocation-table set
    begin-assembly swap >r >r
        generate-code
        generate-reloc
    r> set-compiled-cell
    r> set-compiled-cell ;

SYMBOL: previous-offset

: generate ( word linear -- )
    #! If generation fails, reset compiled offset.
    [
        compiled-offset previous-offset set
        (generate)
    ] [
        [
            previous-offset get set-compiled-offset
            rethrow
        ] when*
    ] catch ;

#label [ save-xt ] "generator" set-word-prop

#end-dispatch [ drop ] "generator" set-word-prop

: type-tag ( type -- tag )
    #! Given a type number, return the tag number.
    dup 6 > [ drop 3 ] when ;

DEFER: compile-call-label ( label -- )
DEFER: compile-jump-label ( label -- )

: compile-call ( word -- ) dup postpone-word compile-call-label ;

#call [
    compile-call
] "generator" set-word-prop

#call-label [
    compile-call-label
] "generator" set-word-prop

#jump-label [
    compile-jump-label
] "generator" set-word-prop

DEFER: compile-jump-t ( label -- )
DEFER: compile-jump-f ( label -- )

#jump-t-label [ compile-jump-t ] "generator" set-word-prop
#jump-t [ compile-jump-t ] "generator" set-word-prop

#jump-f-label [ compile-jump-f ] "generator" set-word-prop
#jump-f [ compile-jump-f ] "generator" set-word-prop

: compile-target ( word -- ) 0 compile-cell absolute ;

#target-label [
    #! Jump table entries are absolute addresses.
    compile-target
] "generator" set-word-prop

#target [
    #! Jump table entries are absolute addresses.
    dup postpone-word  compile-target
] "generator" set-word-prop
