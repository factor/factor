! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io kernel namespaces parser prettyprint sequences
words assocs definitions generic quotations effects
slots continuations tuples debugger combinators
vocabs help.stylesheet help.topics help.crossref help.markup
sorting ;
IN: help

GENERIC: word-help* ( word -- content )

: word-help ( word -- content )
    dup "help" word-prop [ ] [
        dup word-help* dup
        [ swap 2array 1array ] [ 2drop f ] if
    ] ?if ;

M: word word-help* drop f ;

M: slot-reader word-help* drop \ $slot-reader ;

M: slot-writer word-help* drop \ $slot-writer ;

: all-articles ( -- seq )
    articles get keys
    all-words [ word-help ] subset append ;

: xref-help ( -- )
    all-articles [ xref-article ] each ;

: error? ( word -- ? )
    \ $error-description swap word-help elements empty? not ;

: sort-articles ( seq -- newseq )
    [ dup article-title ] { } map>assoc sort-values 0 <column> ;

: all-errors ( -- seq )
    all-words [ error? ] subset sort-articles ;

M: word article-name word-name ;

M: word article-title
    dup parsing? over symbol? or [
        word-name
    ] [
        dup word-name
        swap stack-effect
        [ effect>string " " swap 3append ] when*
    ] if ;

M: word article-content
    [
        \ $vocabulary over 2array ,
        dup word-help %
        \ $related over 2array ,
        dup get-global [ \ $value swap 2array , ] when*
        \ $definition swap 2array ,
    ] { } make ;

M: word article-parent "help-parent" word-prop ;

M: word set-article-parent swap "help-parent" set-word-prop ;

: $doc-path ( article -- )
    help-path dup empty? [
        drop
    ] [
        [
            help-path-style get [
                "Parent topics: " write $links
            ] with-style
        ] ($block)
    ] if ;

: $title ( topic -- )
    title-style get [
        title-style get [
            dup [
                dup article-title swap >link write-object
            ] ($block) $doc-path
        ] with-nesting
    ] with-style nl ;

: help ( topic -- )
    last-element off dup $title
    article-content print-content nl ;

: about ( vocab -- )
    dup vocab-help [
        help
    ] [
        "The " write vocab-name write
        " vocabulary does not define a main help article." print
        "To define one, refer to \\ ABOUT: help" print
    ] ?if ;

: ($index) ( articles -- )
    subsection-style get [
        sort-articles [ nl ] [ ($subsection) ] interleave
    ] with-style ;

: $index ( element -- )
    first call dup empty?
    [ drop ] [ [ ($index) ] ($block) ] if ;

: $about ( element -- )
    first vocab-help [ 1array $subsection ] when* ;

: (:help-multi)
    "This error has multiple delegates:" print
    ($index) nl ;

: (:help-none)
    drop "No help for this error. " print ;

: :help ( -- )
    error get delegates [ error-help ] map [ ] subset
    {
        { [ dup empty? ] [ (:help-none) ] }
        { [ dup length 1 = ] [ first help ] }
        { [ t ] [ (:help-multi) ] }
    } cond ;

: remove-article ( name -- )
    dup articles get key? [
        dup unxref-article
        dup articles get delete-at
    ] when drop ;

: add-article ( article name -- )
    [ remove-article ] keep
    [ articles get set-at ] keep
    xref-article ;

: remove-word-help ( word -- )
    dup word-help [ dup unxref-article ] when
    f "help" set-word-prop ;

: set-word-help ( content word -- )
    [ remove-word-help ] keep
    [ swap "help" set-word-prop ] keep
    xref-article ;
