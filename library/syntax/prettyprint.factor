! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: prettyprint
USING: alien arrays generic hashtables io kernel lists math
namespaces parser sequences strings styles vectors words ;

! State
SYMBOL: column
SYMBOL: indent
SYMBOL: last-newline
SYMBOL: recursion-check
SYMBOL: line-count
SYMBOL: end-printing

! Configuration
SYMBOL: tab-size
SYMBOL: margin
SYMBOL: nesting-limit
SYMBOL: length-limit
SYMBOL: line-limit
SYMBOL: string-limit

global [
    4 tab-size set
    64 margin set
    recursion-check off
    0 column set
    0 indent set
    0 last-newline set
    1 line-count set
    string-limit off
] bind

TUPLE: pprinter stack ;

GENERIC: pprint-section*

TUPLE: section start end nl-after? indent ;

C: section ( length -- section )
    >r column [ dup rot + dup ] change r>
    [ set-section-end ] keep
    [ set-section-start ] keep
    0 over set-section-indent ;

: line-limit? ( -- ? )
    line-limit get dup [ line-count get <= ] when ;

: do-indent indent get CHAR: \s fill write ;

: fresh-line ( n -- )
    #! n is current column position.
    dup last-newline get = [
        drop
    ] [
        last-newline set
        line-limit? [ "..." write end-printing get continue ] when
        line-count inc
        "\n" write do-indent
    ] if ;

TUPLE: text string style ;

C: text ( string style -- section )
    pick length 1+ <section> over set-delegate
    [ set-text-style ] keep
    [ set-text-string ] keep ;

M: text pprint-section*
    dup text-string swap text-style format ;

TUPLE: block sections ;

C: block ( -- block )
    0 <section> over set-delegate
    V{ } clone over set-block-sections
    t over set-section-nl-after?
    tab-size get over set-section-indent ;

: pprinter-block pprinter-stack peek ;

: block-empty? ( section -- ? )
    dup block? [ block-sections empty? ] [ drop f ] if ;

: add-section ( section stream -- )
    over block-empty? [
        2drop
    ] [
        pprinter-block block-sections push
    ] if ;

: text ( string style -- ) <text> pprinter get add-section ;

: <indent ( section -- ) section-indent indent [ + ] change ;

: indent> ( section -- ) section-indent indent [ swap - ] change ;

: inset-section ( section -- )
    dup <indent
    dup section-start fresh-line dup pprint-section*
    dup indent>
    dup section-nl-after?
    [ section-end fresh-line ] [ drop ] if ;

: section-fits? ( section -- ? )
    margin get dup 0 = [
        2drop t
    ] [
        line-limit? pick block? and [
            2drop t
        ] [
            >r section-end last-newline get - indent get + r> <=
        ] if
    ] if ;

: pprint-section ( section -- )
    dup section-fits?
    [ pprint-section* ] [ inset-section ] if ;

TUPLE: newline ;

C: newline ( -- section )
    0 <section> over set-delegate ;

M: newline pprint-section* ( newline -- )
    section-start fresh-line ;

: advance ( section -- )
    dup newline? [
        drop
    ] [
        section-start last-newline get = [ " " write ] unless
    ] if ;

M: block pprint-section* ( block -- )
    f swap block-sections [
        over [ dup advance ] when pprint-section drop t
    ] each drop ;

: <block ( -- ) <block> pprinter get pprinter-stack push ;

: newline ( -- ) <newline> pprinter get add-section ;

: end-block ( block -- ) column get swap set-section-end ;

: pop-block ( pprinter -- ) pprinter-stack pop drop ;

: (block>) ( -- )
    pprinter get dup pprinter-block
    dup end-block swap dup pop-block add-section ;

: last-block? ( -- ? )
    pprinter get pprinter-stack length 1 = ;

: block> ( -- )
    #! Protect against malformed <block ... block> forms.
    last-block? [ (block>) ] unless ;

: block; ( -- )
    pprinter get pprinter-block f swap set-section-nl-after?
    block> ;

: end-blocks ( -- ) last-block? [ (block>) end-blocks ] unless ;

C: pprinter ( -- stream )
    <block> 1 <vector> [ push ] keep over set-pprinter-stack ;

: do-pprint ( pprinter -- )
    [
        end-printing set
        dup pprinter-block pprint-section
    ] callcc0 drop ;

GENERIC: pprint* ( obj -- )

: vocab-style ( vocab -- style )
    H{
        [[ "syntax" [ [[ foreground { 0.5 0.5 0.5 1.0 } ]] ] ]]
        [[ "kernel" [ [[ foreground { 0.0 0.0 0.5 1.0 } ]] ] ]]
        [[ "sequences" [ [[ foreground { 0.5 0.0 0.0 1.0 } ]] ] ]]
        [[ "math" [ [[ foreground { 0.0 0.5 0.0 1.0 } ]] ] ]]
        [[ "math-internals" [ [[ foreground { 0.75 0.0 0.0 1.0 } ]] ] ]]
        [[ "kernel-internals" [ [[ foreground { 0.75 0.0 0.0 1.0 } ]] ] ]]
        [[ "io-internals" [ [[ foreground { 0.75 0.0 0.0 1.0 } ]] ] ]]
    } hash ;

: word-style ( word -- style )
    dup word-vocabulary vocab-style swap presented swons add ;

: pprint-word ( obj -- )
    dup word-name [ "( unnamed )" ] unless*
    swap word-style text ;

M: object pprint* ( obj -- )
    "( unprintable object: " swap class word-name " )" append3
    f text ;

M: real pprint* ( obj -- ) number>string f text ;

: ch>ascii-escape ( ch -- esc )
    H{
        [[ CHAR: \e "\\e"  ]]
        [[ CHAR: \n "\\n"  ]]
        [[ CHAR: \r "\\r"  ]]
        [[ CHAR: \t "\\t"  ]]
        [[ CHAR: \0 "\\0"  ]]
        [[ CHAR: \\ "\\\\" ]]
        [[ CHAR: \" "\\\"" ]]
    } hash ;

: ch>unicode-escape ( ch -- esc )
    >hex 4 CHAR: 0 pad-left "\\u" swap append ;

: unparse-ch ( ch -- ch/str )
    dup quotable? [
        ,
    ] [
        dup ch>ascii-escape [ ] [ ch>unicode-escape ] ?if %
    ] if ;

: do-string-limit ( string -- string )
    string-limit get [
        dup length margin get > [
            margin get 3 - swap head "..." append
        ] when
    ] when ;

: pprint-string ( string prefix -- )
    [ % [ unparse-ch ] each CHAR: " , ] "" make
    do-string-limit f text ;

M: string pprint* ( str -- str ) "\"" pprint-string ;

M: sbuf pprint* ( str -- str ) "SBUF\" " pprint-string ;

M: word pprint* ( word -- )
    dup "pprint-close" word-prop [ block> ] when
    dup pprint-word
    "pprint-open" word-prop [ <block ] when ;

M: f pprint* drop "f" f text ;

M: dll pprint* ( obj -- str ) dll-path "DLL\" " pprint-string ;

: nesting-limit? ( -- ? )
    nesting-limit get dup
    [ pprinter get pprinter-stack length < ] when ;

: check-recursion ( obj quot -- indent )
    #! We detect circular structure.
    nesting-limit? [
        2drop "#" f text
    ] [
        over recursion-check get memq? [
            2drop "&" f text
        ] [
            over recursion-check [ cons ] change
            call
            recursion-check [ cdr ] change
        ] if
    ] if ; inline

: length-limit? ( seq -- seq ? )
    length-limit get dup
    [ swap 2dup length < [ head t ] [ nip f ] if ]
    [ drop f ] if ;

: pprint-element ( object -- )
    dup parsing? [ \ POSTPONE: pprint-word ] when pprint* ;

: pprint-elements ( seq -- )
    length-limit? >r
    [ pprint-element ] each
    r> [ "..." f text ] when ;

: pprint-sequence ( seq start end -- )
    swap pprint* swap pprint-elements pprint* ;

M: complex pprint* ( num -- )
    >rect 2array \ C{ \ } pprint-sequence ;

M: cons pprint* ( list -- )
   [
       dup list? [ \ [ \ ] ] [ uncons 2array \ [[ \ ]] ] if
       pprint-sequence
   ] check-recursion ;

M: array pprint* ( vector -- )
    [ \ { \ } pprint-sequence ] check-recursion ;

M: vector pprint* ( vector -- )
    [ \ V{ \ } pprint-sequence ] check-recursion ;

M: hashtable pprint* ( hashtable -- )
    [ hash>alist \ H{ \ } pprint-sequence ] check-recursion ;

M: tuple pprint* ( tuple -- )
    [
        \ T{ pprint*
        tuple>array dup first pprint*
        <block 1 swap tail-slice pprint-elements block>
        \ } pprint*
    ] check-recursion ;

M: alien pprint* ( alien -- )
    dup expired? [
        drop "( alien expired )"
    ] [
        \ ALIEN: pprint-word alien-address number>string
    ] if f text ;

M: wrapper pprint* ( wrapper -- )
    dup wrapped word? [
        \ \ pprint-word wrapped pprint-word
    ] [
        wrapped 1array \ W{ \ } pprint-sequence
    ] if ;

: with-pprint ( quot -- )
    [
        <pprinter> pprinter set call end-blocks
        pprinter get do-pprint
    ] with-scope ; inline

: pprint ( object -- ) [ pprint* ] with-pprint ;

: . ( obj -- ) pprint terpri ;

: unparse ( object -- str ) [ pprint ] string-out ;

: pprint-short ( object -- string )
    [
        1 line-limit set
        20 length-limit set
        2 nesting-limit set
        string-limit on
        pprint
    ] with-scope ;

: short. ( object -- ) pprint-short terpri ;

: unparse-short ( object -- string ) [ pprint-short ] string-out ;

! For integers only
: .b >bin print ;
: .o >oct print ;
: .h >hex print ;

: define-open
    #! The word will be pretty-printed as a block opener.
    t "pprint-open" set-word-prop ;

: define-close ( word -- )
    #! The word will be pretty-printed as a block closer.
    t "pprint-close" set-word-prop ;

{ 
    POSTPONE: [ POSTPONE: [[
    POSTPONE: { POSTPONE: V{ POSTPONE: H{
    POSTPONE: T{ POSTPONE: W{
} [ define-open ] each

{ POSTPONE: [ POSTPONE: } POSTPONE: ]] }
[ define-close ] each
