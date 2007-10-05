! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays generic hashtables io kernel math assocs
namespaces sequences strings io.styles vectors words
prettyprint.config splitting classes continuations
io.streams.nested ;
IN: prettyprint.sections

! State
SYMBOL: position
SYMBOL: recursion-check
SYMBOL: pprinter-stack

SYMBOL: last-newline
SYMBOL: line-count
SYMBOL: end-printing
SYMBOL: indent

! We record vocabs of all words
SYMBOL: pprinter-in
SYMBOL: pprinter-use

: record-vocab ( word -- )
    word-vocabulary [ dup pprinter-use get set-at ] when* ;

! Utility words
: line-limit? ( -- ? )
    line-limit get dup [ line-count get <= ] when ;

: do-indent ( -- ) indent get CHAR: \s <string> write ;

: fresh-line ( n -- )
    dup last-newline get = [
        drop
    ] [
        last-newline set
        line-limit? [ "..." write end-printing get continue ] when
        line-count inc
        nl do-indent
    ] if ;

: text-fits? ( len -- ? )
    margin get dup zero?
    [ 2drop t ] [ >r indent get + r> <= ] if ;

! break only if position margin 2 / >
SYMBOL: soft

! always breaks
SYMBOL: hard

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

: <section> ( style length -- section )
    position [ dup rot + dup ] change 0 {
        set-section-style
        set-section-start
        set-section-end
        set-section-overhang
    } section construct ;

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

: <break> ( type -- section )
    H{ } 0 <section>
    { set-break-type set-delegate } \ break construct ;

M: break short-section drop ;

M: break long-section drop ;

! Block sections
TUPLE: block sections ;

: <block> ( style -- block )
    0 <section> V{ } clone
    { set-delegate set-block-sections } block construct ;

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
    ] curry* each ; inline

M: block short-section ( block -- )
    [ advance ] pprint-sections ;

: do-break ( break -- )
    dup break-type hard eq?
    over section-end last-newline get - margin get 2/ > or
    [ <fresh-line ] [ drop ] if ;

: empty-block? ( block -- ? ) block-sections empty? ;

: if-nonempty ( block quot -- )
    >r dup empty-block? [ drop ] r> if ; inline

: (<block) pprinter-stack get push ;

: <block H{ } <block> (<block) ;

: <object ( obj -- ) presented associate <block> (<block) ;

! Text section
TUPLE: text string ;

: <text> ( string style -- text )
    over length 1+ <section>
    { set-text-string set-delegate }
    \ text construct ;

M: text short-section text-string write ;

M: text long-section short-section ;

: styled-text ( string style -- ) <text> add-section ;

: text ( string -- ) H{ } styled-text ;

! Inset section
TUPLE: inset narrow? ;

: <inset> ( narrow? -- block )
    2 H{ } <block>
    { set-inset-narrow? set-section-overhang set-delegate }
    inset construct ;

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

: <flow> ( -- block )
    H{ } <block> flow construct-delegate ;

M: flow short-section? ( section -- ? )
    #! If we can make room for this entire block by inserting
    #! a newline, do it; otherwise, don't bother, print it as
    #! a short section
    dup section-fits?
    over section-end rot section-start - text-fits? not or ;

: <flow ( -- ) <flow> (<block) ;

! Colon definition section
TUPLE: colon ;

: <colon> ( -- block )
    H{ } <block> colon construct-delegate ;

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
SYMBOL: next

: split-groups [ t , ] when ;

M: f section-start-group? drop t ;

M: f section-end-group? drop f ;

: split-before ( section -- )
    dup section-start-group? prev get section-end-group? and
    swap flow? prev get flow? not and
    or split-groups ;

: split-after ( section -- )
    section-end-group? split-groups ;

: group-flow ( seq -- newseq )
    [
        dup length [
            2dup 1- swap ?nth prev set
            2dup 1+ swap ?nth next set
            swap nth dup split-before dup , split-after
        ] curry* each
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
