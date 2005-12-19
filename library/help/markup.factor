! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
USING: arrays gadgets gadgets-panes gadgets-presentations
hashtables words io kernel lists namespaces prettyprint
sequences strings styles ;

! Simple markup language.

! <element> ::== <string> | <simple-element> | <fancy-element>
! <simple-element> ::== { <element>* }
! <fancy-element> ::== { <type> <element> }

! Element types are words whose name begins with $.

PREDICATE: array simple-element
    dup empty? [ drop t ] [ first word? not ] if ;

M: string print-element format* ;

M: array print-element
    dup first >r 1 swap tail r> execute ;

: ($span) ( content style -- )
    [ print-element ] with-style ;

: ($block) ( content style -- )
    terpri dup [
        [ print-element terpri ] with-style
    ] with-nesting terpri ;

: $see ( content -- ) first see ;

! Some spans

: $heading heading-style ($block) ;

: $subheading subheading-style ($block) ;

: $parameter parameter-style ($span) ;

! Some blocks
: wrap-string ( string -- )
    " " split [
        dup empty? [ dup format* bl ] unless drop
    ] each ;

: ($paragraph) ( element style -- )
    dup [
        [
            [
                dup string?
                [ wrap-string ] [ print-element bl ] if
            ] each
        ] with-style
    ] with-nesting terpri ;

M: simple-element print-element paragraph-style ($paragraph) ;

: $code code-style ($block) ;

! Some links
TUPLE: link name ;

M: link article-title link-name article-title ;

M: link article-content link-name article-content ;

DEFER: help

: ($link) dup article-title swap ;

: $subsection ( object -- )
    subheading-style [
        first <link> ($link) dup [ link-name help ] curry
        simple-outliner
    ] with-style ;

: $link ( article -- ) first <link> ($link) simple-object ;

: $glossary ( element -- ) first <term> ($link) simple-object ;
