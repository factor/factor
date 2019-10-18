! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint
USING: alien arrays generic assocs io kernel math
namespaces sequences strings styles vectors words
prettyprint-internals ;

: make-pprint ( obj quot -- block in use )
    [
        0 position set
        H{ } clone pprinter-use set
        V{ } clone recursion-check set
        V{ } clone pprinter-stack set
        over <object
        call
        pprinter-block
        pprinter-in get
        pprinter-use get keys
    ] with-scope ; inline

: with-pprint ( obj quot -- )
    make-pprint 2drop do-pprint ; inline

: pprint-vocab ( vocab -- )
    dup <vocab-link> present-text ;

: write-in ( vocab -- )
    dup <vocab-link>
    [ \ IN: pprint-word present-text ] with-pprint ;

: in. ( vocab -- )
    [ write-in nl ] when* ;

: use. ( seq -- )
    dup empty? [ drop ] [
        natural-sort [
            \ USING: pprint-word
            [ pprint-vocab ] each
            \ ; pprint-word
        ] with-pprint nl
    ] if ;

: vocabs. ( in use -- )
    dupd remove [ { "syntax" "scratchpad" } member? not ] subset
    use. in. ;

: with-use ( obj quot -- )
    make-pprint vocabs. do-pprint ; inline

: with-in ( obj quot -- )
    make-pprint drop [ write-in bl ] when* do-pprint ; inline

: pprint ( obj -- ) [ pprint* ] with-pprint ;

: . ( obj -- )
    H{
       { length-limit 1000 }
       { nesting-limit 10 }
    } clone [ pprint ] bind nl ;

: pprint-use ( obj -- str ) [ pprint* ] with-use ;

: unparse ( obj -- str ) [ pprint ] string-out ;

: unparse-use ( obj -- ) [ pprint-use ] string-out ;

: pprint-short ( obj -- )
    H{
       { line-limit 1 }
       { length-limit 15 }
       { nesting-limit 2 }
       { string-limit t }
    } clone [ pprint ] bind ;

: short. ( obj -- ) pprint-short nl ;

: .b ( n -- ) >bin print ;
: .o ( n -- ) >oct print ;
: .h ( n -- ) >hex print ;

: stack. ( seq -- ) [ short. ] each ;

: .s ( -- ) datastack stack. ;
: .r ( -- ) retainstack stack. ;

: callframe. ( seq pos -- )
    [
        hilite-index set
        dup hilite-quotation set
        2 nesting-limit set
        .
    ] with-scope ;

: callstack. ( seq -- )
    3 <groups> [ first2 1- callframe. ] each ;

: .c ( -- ) callstack callstack. ;

: pprint-cell ( obj -- ) [ pprint ] with-cell ;
