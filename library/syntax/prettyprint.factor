! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: alien generic hashtables io kernel lists math namespaces
parser sequences strings styles unparser vectors words ;

! TODO:
! - newline styles: forced, long output style, normal
! - long output flag, off with .
! - margin & indent calculation fix
! - out of memory when printing global namespace
! - formatting HTML code
! - limit strings
! - merge unparse into this

! State
SYMBOL: column
SYMBOL: indent
SYMBOL: last-newline?
SYMBOL: last-newline
SYMBOL: recursion-check
SYMBOL: line-count
SYMBOL: end-printing

! Configuration
SYMBOL: margin
SYMBOL: nesting-limit
SYMBOL: length-limit
SYMBOL: line-limit

global [
    64 margin set
    recursion-check off
    0 column set
    0 indent set
    last-newline? off
    0 last-newline set
    0 line-count set
] bind

TUPLE: pprinter blocks block ;

GENERIC: pprint-section*

TUPLE: section start end ;

C: section ( length -- section )
    >r column [ dup rot + dup ] change r>
    [ set-section-end ] keep
    [ set-section-start ] keep ;

: section-fits? ( section -- ? )
    section-end last-newline get - margin get <= ;

: line-limit? ( -- ? )
    line-limit get dup [ line-count get <= ] when ;

: fresh-line ( section -- )
    section-start last-newline set
    line-count [ 1 + ] change
    line-limit? [ " ..." write end-printing get call ] when
    terpri indent get CHAR: \s fill write ;

TUPLE: text string style ;

C: text ( string style -- section )
    pick length <section> over set-delegate
    [ set-text-style ] keep
    [ set-text-string ] keep ;

M: text pprint-section*
    dup text-string swap text-style format ;

TUPLE: block sections ;

C: block ( -- block )
    0 <section> over set-delegate
    { } clone over set-block-sections ;

: add-section ( section stream -- )
    pprinter-block block-sections push ;

: text ( string style -- )
    <text> pprinter get add-section ;

: bl ( -- ) " " f text ;

: pprint-section ( section -- )
    last-newline? get [
        dup section-fits? [
            " " write
        ] [
            dup fresh-line
        ] ifte last-newline? off
    ] when pprint-section* ;

TUPLE: newline forced? ;

C: newline ( forced -- section )
    1 <section> over set-delegate
    [ set-newline-forced? ] keep ;

M: newline pprint-section*
    dup newline-forced?
    [ fresh-line ] [ drop last-newline? on ] ifte ;

: section-length ( section -- n )
    dup section-end swap section-start - ;

: block-indent ( block -- indent )
    block-sections first
    dup block? [ drop 0 ] [ section-length 1 + ] ifte ;

M: block pprint-section* ( block -- )
    indent get dup >r
    over block-indent + indent set
    block-sections [ pprint-section ] each
    r> indent set ;

: <block ( -- )
    pprinter get dup pprinter-block over pprinter-blocks push
    <block> swap set-pprinter-block ;

: newline ( forced -- )
    <newline> pprinter get add-section ;

: end-block ( block -- )
    column get swap set-section-end ;

: pop-block ( pprinter -- )
    dup pprinter-blocks pop swap set-pprinter-block ;

: block-empty? block-sections empty? ;

: block> ( -- )
    pprinter get dup pprinter-block dup block-empty? [
        drop pop-block
    ] [
        dup end-block swap dup pop-block add-section
    ] ifte ;

C: pprinter ( -- stream )
    { } clone over set-pprinter-blocks
    <block> over set-pprinter-block ;

: do-pprint ( pprinter -- )
    [
        end-printing set
        dup pprinter-block pprint-section
    ] callcc0 drop ;

GENERIC: pprint* ( obj -- )

: vocab-style ( vocab -- style )
    {{
        [[ "syntax" [ [[ foreground [ 128 128 128 ] ]] ] ]]
        [[ "kernel" [ [[ foreground [ 0 0 128 ] ]] ] ]]
        [[ "sequences" [ [[ foreground [ 128 0 0 ] ]] ] ]]
        [[ "math" [ [[ foreground [ 0 128 0 ] ]] ] ]]
        [[ "math-internals" [ [[ foreground [ 192 0 0 ] ]] ] ]]
        [[ "kernel-internals" [ [[ foreground [ 192 0 0 ] ]] ] ]]
        [[ "io-internals" [ [[ foreground [ 192 0 0 ] ]] ] ]]
    }} hash ;

: object-style ( obj -- style )
    dup word? [ dup word-vocabulary vocab-style ] [ { } ] ifte
    swap presented swons add ;

: pprint-object ( obj -- )
    dup unparse swap object-style text ;

M: object pprint* ( obj -- )
    pprint-object ;

M: word pprint* ( word -- )
    dup parsing? [ \ POSTPONE: pprint-object bl ] when
    pprint-object ;

: nesting-limit? ( -- ? )
    nesting-limit get dup
    [ pprinter get pprinter-blocks length < ] when ;

: check-recursion ( obj quot -- indent )
    #! We detect circular structure.
    nesting-limit? [
        2drop "&" f text
    ] [
        over recursion-check get memq? [
            2drop "#" f text
        ] [
            over recursion-check [ cons ] change
            call
            recursion-check [ cdr ] change
        ] ifte
    ] ifte ; inline

: length-limit? ( seq -- seq ? )
    length-limit get dup
    [ swap 2dup length < [ head t ] [ nip f ] ifte ]
    [ drop f ] ifte ;

: pprint-elements ( seq -- )
    length-limit? >r
    [ pprint* f newline ] each
    r> [ "... " f text ] when ;

: pprint-sequence ( seq start end -- )
    <block swap pprint-object f newline
    swap pprint-elements pprint-object block> ;

M: cons pprint* ( list -- )
   [
       dup list? [ \ [ \ ] ] [ uncons 2list \ [[ \ ]] ] ifte
       pprint-sequence
   ] check-recursion ;

M: vector pprint* ( vector -- )
    [ \ { \ } pprint-sequence ] check-recursion ;

M: hashtable pprint* ( hashtable -- )
    [ hash>alist \ {{ \ }} pprint-sequence ] check-recursion ;

M: tuple pprint* ( tuple -- )
    [ <mirror> \ << \ >> pprint-sequence ] check-recursion ;

M: alien pprint* ( alien -- )
    \ ALIEN: pprint-object bl alien-address pprint-object ;

M: wrapper pprint* ( wrapper -- )
    dup wrapped word? [
        \ \ pprint-object bl wrapped pprint-object
    ] [
        wrapped 1vector \ W[ \ ]W pprint-sequence
    ] ifte ;

: with-pprint ( quot -- )
    [
        <pprinter> pprinter set call pprinter get do-pprint
    ] with-scope ; inline

: pprint ( object -- )
    [ pprint* ] with-pprint ;

: pprint>string ( object -- string )
    [ pprint ] string-out ;

: . ( obj -- ) pprint terpri ;

: pprint-short ( object -- string )
    [
        1 line-limit set
        5 length-limit set
        2 nesting-limit set
        pprint
    ] with-scope ;

: pprint>short-string ( object -- string )
    [ pprint-short ] string-out ;

: [.] ( sequence -- )
    #! Unparse each element on its own line.
    [ [ pprint>short-string print ] each ] with-scope ;

: stack. reverse-slice [.] ;

: .s datastack stack. ;
: .r callstack stack. ;

! For integers only
: .b >bin print ;
: .o >oct print ;
: .h >hex print ;
