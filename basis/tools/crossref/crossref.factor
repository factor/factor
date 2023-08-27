! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bit-arrays byte-arrays
byte-vectors combinators.short-circuit combinators.smart
compiler.units generic generic.single hash-sets.identity
hashtables help help.crossref help.markup help.topics init io
io.pathnames io.styles kernel lists math.bits namespaces
quotations ranges sbufs see sequences sets sorting source-files
specialized-arrays strings threads vocabs words ;
IN: tools.crossref
SYMBOL: crossref

GENERIC: uses ( defspec -- seq )

<PRIVATE

SYMBOL: visited

GENERIC#: quot-uses 1 ( obj set -- )

UNION: ignored-sequences
    iota
    range
    bits
    byte-array
    byte-vector
    sbuf
    string
    specialized-array
    bit-array ;

M: ignored-sequences quot-uses 2drop ;
M: object quot-uses 2drop ;

M: word quot-uses over crossref? [ adjoin ] [ 2drop ] if ;

: seq-uses ( seq set -- )
    over visited get ?adjoin [
        [ quot-uses ] curry each
    ] [ 2drop ] if ; inline

: assoc-uses ( assoc' set -- )
    over visited get ?adjoin [
        [ quot-uses ] curry [ bi@ ] curry assoc-each
    ] [ 2drop ] if ; inline

: list-uses ( list set -- )
    over visited get ?adjoin [
        [ quot-uses ] curry leach
    ] [ 2drop ] if ; inline

M: sequence quot-uses seq-uses ;

M: assoc quot-uses assoc-uses ;

M: list quot-uses list-uses ;

M: callable quot-uses seq-uses ;

M: wrapper quot-uses [ wrapped>> ] dip quot-uses ;

M: uninterned-word quot-uses [ def>> ] dip quot-uses ;

M: callable uses
    IHS{ } clone visited [
        HS{ } clone [ quot-uses ] keep members
    ] with-variable ;

M: word uses def>> uses ;

M: link uses
    [ { $subsection $subsections $link $see-also } article-links [ >link ] map ]
    [ { $vocab-link } article-links [ >vocab-link ] map ]
    bi append ;

M: pathname uses
    string>> path>source-file top-level-form>> [ uses ] [ { } ] if* ;

! To make UI browser happy
M: object uses drop f ;
M: ignored-sequences uses drop f ;

: crossref-def ( defspec -- )
    dup uses [ crossref get-global adjoin-at ] with each ;

: defs-to-crossref ( -- seq )
    [
        all-words
        [ [ generic? ] reject ]
        [ [ subwords ] map concat ] bi

        all-articles [ >link ] map

        source-files get keys [ <pathname> ] map
    ] append-outputs ;

: build-crossref ( -- crossref )
    "Computing usage index... " write flush yield
    H{ } clone [
        crossref set-global
        defs-to-crossref [ crossref-def ] each
    ] keep
    "done" print flush ;

: get-crossref ( -- crossref )
    crossref get-global [ build-crossref ] unless* ;

GENERIC: irrelevant? ( defspec -- ? )

M: object irrelevant? drop f ;

M: default-method irrelevant? drop t ;

M: predicate-engine-word irrelevant? drop t ;

PRIVATE>

: usage ( defspec -- seq ) get-crossref at members ;

GENERIC: smart-usage ( defspec -- seq )

M: object smart-usage usage [ irrelevant? ] reject ;

M: method smart-usage "method-generic" word-prop smart-usage ;

M: f smart-usage drop \ f smart-usage ;

: synopsis-alist ( definitions -- alist )
    [ [ synopsis ] keep ] { } map>assoc ;

: definitions. ( alist -- )
    [ write-object nl ] assoc-each ;

: sorted-definitions. ( definitions -- )
    synopsis-alist sort-keys definitions. ;

: usage. ( word -- )
    smart-usage
    [ "No usages." print ] [ sorted-definitions. ] if-empty ;

: vocab-xref ( vocab quot: ( defspec -- seq ) -- vocabs )
    [ [ vocab-name ] [ vocab-words [ generic? ] reject ] bi ] dip map
    [
        [ { [ word? ] [ generic? not ] } 1&& ] filter [
            dup method?
            [ "method-generic" word-prop ] when
            vocabulary>>
        ] map
    ] gather sort remove sift ; inline

: vocabs. ( seq -- )
    [ dup >vocab-link write-object nl ] each ;

: vocab-uses ( vocab -- vocabs ) [ uses ] vocab-xref ;

: vocab-uses. ( vocab -- ) vocab-uses vocabs. ;

: vocab-usage ( vocab -- vocabs ) [ usage ] vocab-xref ;

: vocab-usage. ( vocab -- ) vocab-usage vocabs. ;

<PRIVATE

SINGLETON: invalidate-crossref

M: invalidate-crossref definitions-changed
    ! reset crossref on non-empty definitions or f which
    ! indicates a source-file was parsed, cache otherwise
    drop [ null? not ] [ not ] bi or
    [ f crossref set-global ] when ;

STARTUP-HOOK: [ invalidate-crossref add-definition-observer ]

PRIVATE>
