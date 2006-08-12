! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint
USING: alien arrays generic hashtables io kernel math
namespaces parser sequences strings styles vectors words ;

! State
SYMBOL: position
SYMBOL: last-newline
SYMBOL: recursion-check
SYMBOL: line-count
SYMBOL: end-printing
SYMBOL: indent
SYMBOL: pprinter-stack

! Configuration
SYMBOL: tab-size
SYMBOL: margin
SYMBOL: nesting-limit
SYMBOL: length-limit
SYMBOL: line-limit
SYMBOL: string-limit

! Special trick to highlight a word in a quotation
SYMBOL: hilite-quotation
SYMBOL: hilite-index
SYMBOL: hilite-next?

global [
    4 tab-size set
    64 margin set
    0 position set
    0 indent set
    0 last-newline set
    1 line-count set
    string-limit off
] bind

GENERIC: pprint-section*

TUPLE: section start end nl-after? indent style ;

C: section ( style length -- section )
    >r position [ dup rot + dup ] change r>
    [ set-section-end ] keep
    [ set-section-start ] keep
    [ set-section-style ] keep
    0 over set-section-indent ;

: line-limit? ( -- ? )
    line-limit get dup [ line-count get <= ] when ;

: do-indent indent get CHAR: \s <string> write ;

: fresh-line ( n -- )
    dup last-newline get = [
        drop
    ] [
        last-newline set
        line-limit? [ "..." write end-printing get continue ] when
        line-count inc
        terpri do-indent
    ] if ;

TUPLE: text string ;

C: text ( string style -- section )
    [ >r over length 1+ <section> r> set-delegate ] keep
    [ set-text-string ] keep ;

M: text pprint-section*
    dup text-string swap section-style format ;

TUPLE: block sections ;

C: block ( style -- block )
    [ >r 0 <section> r> set-delegate ] keep
    V{ } clone over set-block-sections
    t over set-section-nl-after?
    tab-size get over set-section-indent ;

: pprinter-block pprinter-stack get peek ;

: block-empty? ( section -- ? )
    dup block? [ block-sections empty? ] [ drop f ] if ;

: add-section ( section -- )
    dup block-empty?
    [ drop ] [ pprinter-block block-sections push ] if ;

: styled-text ( string style -- ) <text> add-section ;

: text ( string -- ) H{ } styled-text ;

: <indent ( section -- ) section-indent indent [ + ] change ;

: indent> ( section -- ) section-indent indent [ swap - ] change ;

: inset-section ( section -- )
    dup <indent
    dup section-start fresh-line dup pprint-section*
    dup indent>
    dup section-nl-after?
    [ section-end fresh-line ] [ drop ] if ;

: section-fits? ( section -- ? )
    margin get dup zero? [
        2drop t
    ] [
        line-limit? pick block? and [
            2drop t
        ] [
            >r section-end last-newline get - indent get + r> <=
        ] if
    ] if ;

: pprint-section ( section -- )
    dup section-fits? [ pprint-section* ] [ inset-section ] if ;

TUPLE: newline ;

C: newline ( -- section )
    H{ } 0 <section> over set-delegate ;

M: newline pprint-section* ( newline -- )
    section-start fresh-line ;

: newline ( -- ) <newline> add-section ;

: advance ( section -- )
    dup newline? [
        drop
    ] [
        section-start last-newline get = [ bl ] unless
    ] if ;

: <style section-style stdio [ <nested-style-stream> ] change ;

: style> stdio [ delegate ] change ;

M: block pprint-section* ( block -- )
    dup <style
    f swap block-sections [
        over [ dup advance ] when pprint-section drop t
    ] each drop
    style> ;

: <block ( style -- ) <block> pprinter-stack get push ;

: end-block ( block -- ) position get swap set-section-end ;

: (block>) ( -- )
    pprinter-stack get pop dup end-block add-section ;

: last-block? ( -- ? ) pprinter-stack get length 1 = ;

: block> ( -- ) last-block? [ (block>) ] unless ;

: block; ( -- )
    pprinter-block f swap set-section-nl-after? block> ;

: end-blocks ( -- ) last-block? [ (block>) end-blocks ] unless ;

: do-pprint ( -- )
    [ end-printing set pprinter-block pprint-section ] callcc0 ;

GENERIC: pprint* ( obj -- )

: word-style ( word -- style )
    [
        dup presented set
        parsing? [ bold font-style set ] when
    ] make-hash ;

: pprint-word ( obj -- )
    dup word-name swap word-style styled-text ;

M: object pprint* ( obj -- )
    "( unprintable object: " swap class word-name " )" append3
    text ;

M: real pprint* ( obj -- ) number>string text ;

: ch>ascii-escape ( ch -- esc )
    H{
        { CHAR: \e "\\e"  }
        { CHAR: \n "\\n"  }
        { CHAR: \r "\\r"  }
        { CHAR: \t "\\t"  }
        { CHAR: \0 "\\0"  }
        { CHAR: \\ "\\\\" }
        { CHAR: \" "\\\"" }
    } hash ;

: ch>unicode-escape ( ch -- esc )
    >hex 4 CHAR: 0 pad-left "\\u" swap append ;

: unparse-ch ( ch -- )
    dup quotable? [
        ,
    ] [
        dup ch>ascii-escape [ ] [ ch>unicode-escape ] ?if %
    ] if ;

: do-string-limit ( string -- string )
    string-limit get [
        dup length margin get > [
            margin get 3 - head "..." append
        ] when
    ] when ;

: pprint-string ( string prefix -- )
    [ % [ unparse-ch ] each CHAR: " , ] "" make
    do-string-limit text ;

M: string pprint* ( str -- str ) "\"" pprint-string ;

M: sbuf pprint* ( str -- str ) "SBUF\" " pprint-string ;

M: word pprint* ( word -- )
    dup "pprint-close" word-prop [ block> ] when
    dup pprint-word
    "pprint-open" word-prop [ H{ } <block ] when ;

M: f pprint* drop \ f pprint-word ;

M: dll pprint* ( obj -- str ) dll-path "DLL\" " pprint-string ;

: nesting-limit? ( -- ? )
    nesting-limit get dup [ pprinter-stack get length < ] when ;

: check-recursion ( obj quot -- )
    nesting-limit? [
        2drop "#" text
    ] [
        over recursion-check get memq? [
            2drop "&" text
        ] [
            over recursion-check get push
            call
            recursion-check get pop*
        ] if
    ] if ; inline

: length-limit? ( seq -- seq ? )
    length-limit get dup
    [ over length over > [ head t ] [ drop f ] if ]
    [ drop f ] if ;

: pprint-element ( object -- )
    dup parsing? [ \ POSTPONE: pprint-word ] when pprint* ;

: hilite-style ( -- hash )
    H{
        { background { 0.9 0.9 0.9 1 } }
        { highlight t }
    } ;

: pprint-hilite ( object n -- )
    hilite-index get = [
        hilite-style <block pprint-element block>
    ] [
        pprint-element
    ] if ;

: pprint-elements ( seq -- )
    length-limit? >r dup hilite-quotation get eq? [
        dup length [ pprint-hilite ] 2each
    ] [
        [ pprint-element ] each
    ] if r> [ "..." text ] when ;

: pprint-sequence ( seq start end -- )
    swap pprint* swap pprint-elements pprint* ;

M: complex pprint* ( num -- )
    >rect 2array \ C{ \ } pprint-sequence ;

M: quotation pprint* ( list -- )
    [ \ [ \ ] pprint-sequence ] check-recursion ;

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
        H{ } <block 1 tail-slice pprint-elements
        \ } pprint*
    ] check-recursion ;

M: alien pprint* ( alien -- )
    dup expired? [
        drop "( alien expired )"
    ] [
        \ ALIEN: pprint-word alien-address number>string
    ] if text ;

M: wrapper pprint* ( wrapper -- )
    dup wrapped word? [
        \ \ pprint-word wrapped pprint-word
    ] [
        wrapped 1array \ W{ \ } pprint-sequence
    ] if ;

: with-pprint ( quot -- )
    [
        V{ } clone recursion-check set
        H{ } <block> f ?push pprinter-stack set
        call end-blocks do-pprint
    ] with-scope ; inline

: pprint ( object -- ) [ pprint* ] with-pprint ;

: . ( obj -- )
    H{
       { length-limit 1000 }
       { nesting-limit 10 }
    } clone [ pprint ] bind terpri ;

: unparse ( object -- str ) [ pprint ] string-out ;

: pprint-short ( object -- string )
    H{
       { line-limit 1 }
       { length-limit 15 }
       { nesting-limit 2 }
       { string-limit t }
    } clone [ pprint ] bind ;

: short. ( object -- ) pprint-short terpri ;

: unparse-short ( object -- string ) [ pprint-short ] string-out ;

: .b >bin print ;
: .o >oct print ;
: .h >hex print ;

: define-open t "pprint-open" set-word-prop ;
: define-close t "pprint-close" set-word-prop ;

{ 
    POSTPONE: [
    POSTPONE: { POSTPONE: V{ POSTPONE: H{
    POSTPONE: W{
} [ define-open ] each

{
    POSTPONE: ] POSTPONE: }
} [ define-close ] each
