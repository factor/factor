! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays io kernel namespaces prettyprint sequences words ;

M: word article-title
    dup word-name swap stack-effect [ " " swap append3 ] when* ;

M: word article-content
    [
        \ $vocabulary over 2array ,
        dup "help" word-prop [
            %
        ] [
            "predicating" word-prop [
                \ $predicate swap 2array ,
            ] when*
        ] ?if
    ] { } make ;

: with-default-style ( quot -- )
    default-char-style [
        default-para-style [ last-block on call ] with-nesting
    ] with-style ; inline

: print-title ( article -- )
    [ dup article-title $title $where ] with-default-style
    terpri ;

: print-content ( element -- )
    [ print-element ] with-default-style ;

: (help) ( topic -- ) article-content print-content terpri ;

: help ( topic -- ) dup print-title (help) ;

: see-help ( word -- )
    dup help [ $definition terpri ] with-default-style ;

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
