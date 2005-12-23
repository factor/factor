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

M: string print-element
    " " split [ format* bl ] each ;

M: array print-element
    dup first >r 1 swap tail r> execute ;

: ($span) ( content style -- )
    [ print-element ] with-style ;

: ($block) ( content style -- )
    terpri*
    [ [ print-element ] with-nesting* ] with-style
    terpri* ;

: $see ( content -- )
    code-style [ [ first see ] with-nesting* ] with-style ;

! Some spans

: $heading heading-style ($block) ;

: $subheading subheading-style ($block) ;

: $parameter parameter-style ($span) ;

: $emphasis emphasis-style ($span) ;

: $url url-style ($span) ;

: $terpri terpri drop ;

! Some blocks
M: simple-element print-element
    current-style [ [ print-element ] each ] with-nesting ;

: $code
    terpri*
    first code-style [ [ format* ] with-nesting* ] with-style
    terpri* ;

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
