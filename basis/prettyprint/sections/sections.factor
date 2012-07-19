! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables io kernel math assocs
namespaces make sequences strings io.styles vectors words
prettyprint.config splitting classes continuations
accessors sets vocabs.parser combinators vocabs
classes.maybe ;
FROM: namespaces => set ;
IN: prettyprint.sections

! State
SYMBOL: position
SYMBOL: recursion-check
SYMBOL: pprinter-stack

! We record vocabs of all words
SYMBOL: pprinter-in
SYMBOL: pprinter-use

TUPLE: pprinter last-newline line-count indent ;

: <pprinter> ( -- pprinter ) 0 1 0 pprinter boa ;

: (record-vocab) ( vocab -- )
    dup pprinter-in get dup [ vocab-name ] when =
    [ drop ] [ pprinter-use get conjoin ] if ;

GENERIC: vocabulary-name ( obj -- string )

M: word vocabulary-name
    vocabulary>> ;

M: maybe vocabulary-name
    class>> vocabulary>> ;

: record-vocab ( word -- )
    vocabulary-name {
        { f [ ] }
        { "syntax" [ ] }
        [ (record-vocab) ]
    } case ;

! Utility words
: line-limit? ( -- ? )
    line-limit get dup [ pprinter get line-count>> <= ] when ;

: do-indent ( -- ) pprinter get indent>> CHAR: \s <string> write ;

: fresh-line ( n -- )
    dup pprinter get last-newline>> = [
        drop
    ] [
        pprinter get last-newline<<
        line-limit? [
            "..." write pprinter get return
        ] when
        pprinter get [ 1 + ] change-line-count drop
        nl do-indent
    ] if ;

: text-fits? ( len -- ? )
    margin get
    [ drop t ] [ [ pprinter get indent>> + ] dip <= ] if-zero ;

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

: new-section ( length class -- section )
    new
        position get >>start
        swap position [ + ] change
        position get >>end
        0 >>overhang ; inline

M: section section-fits? ( section -- ? )
    [ end>> pprinter get last-newline>> - ]
    [ overhang>> ] bi
    + text-fits? ;

M: section indent-section? drop f ;

M: section unindent-first-line? drop f ;

M: section newline-after? drop f ;

M: object short-section? section-fits? ;

: indent+ ( section n -- )
    swap indent-section? [
        pprinter get [ + ] change-indent drop
    ] [ drop ] if ;

: <indent ( section -- ) tab-size get indent+ ;

: indent> ( section -- ) tab-size get neg indent+ ;

: <fresh-line ( section -- )
    start>> fresh-line ;

: fresh-line> ( section -- )
    dup newline-after? [ end>> fresh-line ] [ drop ] if ;

: <long-section ( section -- )
    dup unindent-first-line?
    [ dup <fresh-line <indent ] [ dup <indent <fresh-line ] if ;

: long-section> ( section -- )
    dup indent> fresh-line> ;

: pprint-section ( section -- )
    dup short-section? [
        dup style>> [ short-section ] with-style
    ] [
        [ <long-section ]
        [ dup style>> [ long-section ] with-style ]
        [ long-section> ]
        tri
    ] if ;

! Break section
TUPLE: line-break < section type ;

: <line-break> ( type -- section )
    0 \ line-break new-section
        swap >>type ;

M: line-break short-section drop ;

M: line-break long-section drop ;

! Block sections
TUPLE: block < section sections ;

: new-block ( style class -- block )
    0 swap new-section
        V{ } clone >>sections
        swap >>style ; inline

: <block> ( style -- block )
    block new-block ;

: pprinter-block ( -- block ) pprinter-stack get last ;

: add-section ( section -- )
    pprinter-block sections>> push ;

: last-section ( -- section )
    pprinter-block sections>>
    [ line-break? not ] find-last nip ;

: start-group ( -- )
    last-section t >>start-group? drop ;

: end-group ( -- )
    last-section t >>end-group? drop ;

: advance ( section -- )
    [ start>> pprinter get last-newline>> = not ]
    [ short-section? ] bi
    and [ bl ] when ;

: add-line-break ( type -- ) [ <line-break> add-section ] when* ;

M: block section-fits? ( section -- ? )
    line-limit? [ drop t ] [ call-next-method ] if ;

: pprint-sections ( block advancer -- )
    [
        sections>> [ line-break? not ] filter
        unclip-slice pprint-section
    ] dip
    [ [ pprint-section ] bi ] curry each ; inline

M: block short-section ( block -- )
    [ advance ] pprint-sections ;

: do-break ( break -- )
    [ ]
    [ type>> hard eq? ]
    [ end>> pprinter get last-newline>> - margin get 2/ > ] tri
    or [ <fresh-line ] [ drop ] if ;

: empty-block? ( block -- ? ) sections>> empty? ;

: if-nonempty ( block quot -- )
    [ dup empty-block? [ drop ] ] dip if ; inline

: (<block) ( block -- ) pprinter-stack get push ;

: <block ( -- ) f <block> (<block) ;

: <object ( obj -- ) presented associate <block> (<block) ;

! Text section
TUPLE: text < section string ;

: <text> ( string style -- text )
    over length 1 + \ text new-section
        swap >>style
        swap >>string ;

M: text short-section string>> write ;

M: text long-section short-section ;

: styled-text ( string style -- ) <text> add-section ;

: text ( string -- ) H{ } styled-text ;

! Inset section
TUPLE: inset < block narrow? ;

: <inset> ( narrow? -- block )
    H{ } inset new-block
        2 >>overhang
        swap >>narrow? ;

M: inset long-section
    dup narrow?>> [
        [ <fresh-line ] pprint-sections
    ] [
        call-next-method
    ] if ;

M: inset indent-section? drop t ;

M: inset newline-after? drop t ;

: <inset ( narrow? -- ) <inset> (<block) ;

! Flow section
TUPLE: flow < block ;

: <flow> ( -- block )
    H{ } flow new-block ;

M: flow short-section? ( section -- ? )
    #! If we can make room for this entire block by inserting
    #! a newline, do it; otherwise, don't bother, print it as
    #! a short section
    [ section-fits? ]
    [ [ end>> ] [ start>> ] bi - text-fits? not ] bi
    or ;

: <flow ( -- ) <flow> (<block) ;

! Colon definition section
TUPLE: colon < block ;

: <colon> ( -- block )
    H{ } colon new-block ;

M: colon long-section short-section ;

M: colon indent-section? drop t ;

M: colon unindent-first-line? drop t ;

: <colon ( -- ) <colon> (<block) ;

: save-end-position ( block -- )
    position get >>end drop ;

: block> ( -- )
    pprinter-stack get pop
    [ [ save-end-position ] [ add-section ] bi ] if-nonempty ;

: do-pprint ( block -- )
    <pprinter> pprinter [
        [
            dup style>> [
                [
                    short-section
                ] curry with-return
            ] with-nesting
        ] if-nonempty
    ] with-variable ;

! Long section layout algorithm
: chop-break ( seq -- seq )
    dup last line-break? [ but-last-slice chop-break ] when ;

SYMBOL: prev
SYMBOL: next

: split-groups ( ? -- ) [ t , ] when ;

: split-before ( section -- )
    [ start-group?>> prev get [ end-group?>> ] [ t ] if* and ]
    [ flow? prev get flow? not and ]
    bi or split-groups ;

: split-after ( section -- )
    [ end-group?>> ] [ f ] if* split-groups ;

: group-flow ( seq -- newseq )
    [
        dup length iota [
            2dup 1 - swap ?nth prev set
            2dup 1 + swap ?nth next set
            swap nth dup split-before dup , split-after
        ] with each
    ] { } make { t } split harvest ;

: break-group? ( seq -- ? )
    [ first section-fits? ] [ last section-fits? not ] bi and ;

: ?break-group ( seq -- )
    dup break-group? [ first <fresh-line ] [ drop ] if ;

M: block long-section ( block -- )
    [
        sections>> chop-break group-flow [
            dup ?break-group [
                dup line-break? [
                    do-break
                ] [
                    [ advance ] [ pprint-section ] bi
                ] if
            ] each
        ] each
    ] if-nonempty ;

: pprinter-manifest ( -- manifest )
    <manifest>
    [ [ pprinter-use get keys >vector ] dip search-vocabs<< ]
    [ [ pprinter-in get ] dip current-vocab<< ]
    [ ]
    tri ;

: make-pprint ( obj quot -- block manifest )
    [
        0 position ,,
        H{ } clone pprinter-use ,,
        V{ } clone recursion-check ,,
        V{ } clone pprinter-stack ,,
    ] H{ } make [
        over <object
        call
        pprinter-block
        pprinter-manifest
    ] with-variables ; inline

: with-pprint ( obj quot -- )
    make-pprint drop do-pprint ; inline
