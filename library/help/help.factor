! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays io kernel namespaces prettyprint sequences words ;

M: word article-title
    dup word-name swap stack-effect [ " " swap append3 ] when* ;

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

: $title ( article -- )
    title-style [
        title-style [
            dup [ article-title write ] ($block) $where
        ] with-nesting
    ] with-style terpri ;

: (help) ( topic -- ) article-content print-content ;

: help ( topic -- ) dup $title (help) terpri ;

: see-help ( word -- )
    dup help [ terpri $definition terpri ] with-default-style ;

: handbook ( -- ) "handbook" help ;

: $subtopic ( object -- )
    [
        subtopic-style [
            unclip f rot [ print-content ] curry write-outliner
        ] with-style
    ] ($block) ;

: $subsection ( object -- )
    [ first [ (help) ] swap ($subsection) ] ($block) ;

: $outliner ( content -- )
    first call [ (help) ] help-outliner ;
