! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays io kernel namespaces parser prettyprint sequences
words ;

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
    title-style [
        title-style [
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
        subtopic-style [
            unclip f rot [ print-content ] curry write-outliner
        ] with-style
    ] ($block) ;

: ($subsection) ( object -- )
    [ article-title ] keep >link
    dup [ (help) ] curry
    write-outliner ;

: $subsection ( element -- )
    [
        subsection-style [ first ($subsection) ] with-style
    ] ($block) ;

: help-outliner ( seq quot -- )
    subsection-style [
        sort-articles [ ($subsection) ] [ terpri ] interleave
    ] with-style ;

: $outliner ( element -- )
    first call dup empty?
    [ drop ] [ [ help-outliner ] ($block) ] if ;
