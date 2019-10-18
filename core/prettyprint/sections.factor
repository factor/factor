! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays generic hashtables io kernel math assocs
namespaces sequences strings styles vectors words prettyprint ;
IN: prettyprint

! break only if position margin 2 / >
SYMBOL: soft

! always breaks
SYMBOL: hard

IN: prettyprint-internals

! Section protocol
GENERIC: section-fits? ( section -- ? )

GENERIC: short-section ( section -- )

GENERIC: long-section ( section -- )

GENERIC: indent-section? ( section -- ? )

GENERIC: unindent-first-line? ( section -- ? )

GENERIC: newline-after? ( section -- ? )

GENERIC: short-section? ( section -- ? )

! Sections
TUPLE: section
start end
start-group? end-group?
style overhang ;

C: section ( style length -- section )
    >r position [ dup rot + dup ] change r>
    0 over set-section-overhang
    [ set-section-end ] keep
    [ set-section-start ] keep
    [ set-section-style ] keep ;

M: section section-fits? ( section -- ? )
    dup section-end last-newline get -
    swap section-overhang + text-fits? ;

M: section indent-section? drop f ;

M: section unindent-first-line? drop f ;

M: section newline-after? drop f ;

M: object short-section? section-fits? ;

: change-indent ( section n -- )
    swap indent-section? [ indent +@ ] [ drop ] if ;

: <indent ( section -- ) tab-size get change-indent ;

: indent> ( section -- ) tab-size get neg change-indent ;

: <fresh-line ( section -- )
    section-start fresh-line ;

: fresh-line> ( section -- )
    dup newline-after? [ section-end fresh-line ] [ drop ] if ;

: <long-section ( section -- )
    dup unindent-first-line?
    [ dup <fresh-line <indent ] [ dup <indent <fresh-line ] if ;

: long-section> ( section -- )
    dup indent> fresh-line> ;

: with-style* ( style quot -- )
    swap stdio [ <style-stream> ] change
    call stdio [ delegate ] change ; inline

: pprint-section ( section -- )
    dup short-section? [
        dup section-style [ short-section ] with-style*
    ] [
        dup <long-section
        dup section-style [ dup long-section ] with-style*
        long-section>
    ] if ;

! Break section
TUPLE: break type ;

C: break ( type -- section )
    H{ } 0 <section> over set-delegate
    [ set-break-type ] keep ;

M: break short-section drop ;

M: break long-section drop ;

! Block sections
TUPLE: block sections ;

C: block ( style -- block )
    swap 0 <section> over set-delegate
    V{ } clone over set-block-sections ;

: delegate>block ( obj -- ) H{ } <block> swap set-delegate ;

: pprinter-block ( -- block ) pprinter-stack get peek ;

: add-section ( section -- )
    pprinter-block block-sections push ;

: last-section ( -- section )
    pprinter-block block-sections [ break? not ] find-last nip ;

: hilite-style ( -- hash )
    H{
        { background { 0.9 0.9 0.9 1 } }
        { highlight t }
    } ;

: hilite ( -- )
    last-section
    dup section-style hilite-style union
    swap set-section-style ;

: start-group ( -- )
    t last-section set-section-start-group? ;

: end-group ( -- )
    t last-section set-section-end-group? ;

: advance ( section -- )
    dup section-start last-newline get = not
    swap short-section? and
    [ bl ] when ;

: break ( type -- ) [ <break> add-section ] when* ;

M: block section-fits? ( section -- ? )
    line-limit? [ drop t ] [ delegate section-fits? ] if ;

: pprint-sections ( block advancer -- )
    swap block-sections [ break? not ] subset
    unclip pprint-section [
        dup rot call pprint-section
    ] each-with ; inline

M: block short-section ( block -- )
    [ advance ] pprint-sections ;

: do-break ( break -- )
    dup break-type hard eq?
    over section-end last-newline get - margin get 2 / > or
    [ <fresh-line ] [ drop ] if ;

: empty-block? ( block -- ? ) block-sections empty? ;

: if-nonempty ( block quot -- )
    >r dup empty-block? [ drop ] r> if ; inline

: (<block) pprinter-stack get push ;

: <block H{ } <block> (<block) ;

: <object ( obj -- ) presented associate <block> (<block) ;

! Text section
TUPLE: text string ;

C: text ( string style -- text )
    [ >r over length 1+ <section> r> set-delegate ] keep
    [ set-text-string ] keep ;

M: text short-section text-string write ;

M: text long-section short-section ;

: styled-text ( string style -- ) <text> add-section ;

: text ( string -- ) H{ } styled-text ;

! Inset section
TUPLE: inset narrow? ;

C: inset ( narrow? -- block )
    dup delegate>block
    [ set-inset-narrow? ] keep
    2 over set-section-overhang ;

M: inset long-section
    dup inset-narrow? [
        [ <fresh-line ] pprint-sections
    ] [
        delegate long-section
    ] if ;

M: inset indent-section? drop t ;

M: inset newline-after? drop t ;

: <inset ( narrow? -- ) <inset> (<block) ;

! Flow section
TUPLE: flow ;

C: flow ( -- block ) dup delegate>block ;

M: flow short-section? ( section -- ? )
    #! If we can make room for this entire block by inserting
    #! a newline, do it; otherwise, don't bother, print it as
    #! a short section
    dup section-fits?
    over section-end rot section-start - text-fits? not or ;

: <flow ( -- ) <flow> (<block) ;

! Colon definition section
TUPLE: colon ;

C: colon ( -- block ) dup delegate>block ;

M: colon long-section short-section ;

M: colon indent-section? drop t ;

M: colon unindent-first-line? drop t ;

: <colon ( -- ) <colon> (<block) ;

: save-end-position ( block -- )
    position get swap set-section-end ;

: block> ( -- )
    pprinter-stack get pop
    [ dup save-end-position add-section ] if-nonempty ;

: with-section-state ( quot -- )
    [
        0 indent set
        0 last-newline set
        1 line-count set
        call
    ] with-scope ; inline

: do-pprint ( block -- )
    [
        [
            dup section-style [
                [ end-printing set dup short-section ] callcc0
            ] with-nesting drop
        ] if-nonempty
    ] with-section-state ;

! Long section layout algorithm
: chop-break ( seq -- seq )
    dup peek break? [ 1 head-slice* chop-break ] when ;

SYMBOL: prev

: split-groups [ t , ] when ;

: split-before ( section -- )
    dup section-start-group?
    swap flow? prev get flow? not and or split-groups ;

: split-after ( section -- )
    section-end-group? split-groups ;

: group-flow ( seq -- newseq )
    [
        prev off
        [ dup split-before dup , dup split-after prev set ] each
    ] { } make { t } split [ empty? not ] subset ;

: break-group? ( seq -- ? )
    dup first section-fits? swap peek section-fits? not and ;

: ?break-group ( seq -- )
    dup break-group? [ first <fresh-line ] [ drop ] if ;

M: block long-section ( block -- )
    [
        block-sections chop-break group-flow [
            dup ?break-group [
                dup break? [
                    do-break
                ] [
                    dup advance pprint-section
                ] if
            ] each
        ] each
    ] if-nonempty ;
