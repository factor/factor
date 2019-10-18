! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays io kernel namespaces parser prettyprint sequences
words assocs definitions errors generic quotations ;

: make-element ( word markup -- element )
    swap 2array 1array ;

: word-help ( word -- content )
    {
        {
            [ dup "help" word-prop ]
            [ "help" word-prop ]
        } {
            [ dup "predicating" word-prop ]
            [ \ $predicate make-element ]
        } {
            [ dup "reading" word-prop ]
            [ \ $reader make-element ]
        } {
            [ dup "writing" word-prop ]
            [ \ $writer make-element ]
        } {
            [ t ] [ drop f ]
        }
    } cond ;

: all-articles ( -- seq )
    articles get keys
    all-words [ word-help ] subset append ;

: xref-help ( -- )
    all-articles [ xref-article ] each ;

: error? ( word -- ? )
    \ $error-description swap word-help elements empty? not ;

: all-errors ( -- seq )
    all-words [ error? ] subset sort-articles ;

M: word article-name word-name ;

M: word article-title
    dup parsing? [
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
        \ $definition swap 2array ,
    ] { } make ;

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

: ($subsection) ( object -- )
    [ article-title ] keep >link write-object ;

: $subsection ( element -- )
    [
        subsection-style get [ first ($subsection) ] with-style
    ] ($block) ;

: ($index) ( seq quot -- )
    subsection-style get [
        sort-articles [ nl ] [ ($subsection) ] interleave
    ] with-style ;

: $index ( element -- )
    first call dup empty?
    [ drop ] [ [ ($index) ] ($block) ] if ;

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
    dup word-help [ dup unxref-article ] when drop ;

: set-word-help ( content word -- )
    [ remove-word-help ] keep
    [ swap "help" set-word-prop ] keep
    xref-article ;
