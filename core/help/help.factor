! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays io kernel namespaces parser prettyprint sequences
words hashtables definitions errors generic ;

M: word article-title
    dup parsing? [
        word-name
    ] [
        dup word-name
        swap stack-effect
        [ effect>string " " swap append3 ] when*
    ] if ;

M: word article-content
    [
        \ $vocabulary over 2array ,
        dup word-help [
            %
        ] [
            "predicating" word-prop [
                \ $predicate swap 2array ,
            ] when*
        ] ?if
    ] { } make ;

: $title ( topic -- )
    title-style get [
        title-style get [
            dup [ 1array $link ] ($block) $doc-path
        ] with-nesting
    ] with-style terpri ;

: (help) ( topic -- ) article-content print-content ;

: help ( topic -- ) dup $title (help) terpri ;

: see-help ( word -- )
    dup help terpri $definition terpri ;

: handbook ( -- ) "handbook" help ;

: $subtopic ( element -- )
    [
        subtopic-style get [
            unclip f rot [ print-content ] curry write-outliner
        ] with-style
    ] ($block) ;

: ($subsection) ( object -- )
    [ article-title ] keep >link
    dup [ (help) ] curry
    write-outliner ;

: $subsection ( element -- )
    [
        subsection-style get [ first ($subsection) ] with-style
    ] ($block) ;

: help-outliner ( seq quot -- )
    subsection-style get [
        sort-articles [ ($subsection) ] [ terpri ] interleave
    ] with-style ;

: $outliner ( element -- )
    first call dup empty?
    [ drop ] [ [ help-outliner ] ($block) ] if ;

: remove-article ( name -- )
    dup articles get hash-member? [
        dup unxref-article
        dup articles get remove-hash
    ] when drop ;

: add-article ( article name -- )
    [ remove-article ] keep
    [ articles get set-hash ] keep
    xref-article ;

: remove-word-help ( word -- )
    dup word-help [ dup unxref-article ] when drop ;

: set-word-help ( content word -- )
    [ remove-word-help ] keep
    [ swap "help" set-word-prop ] keep
    xref-article ;
