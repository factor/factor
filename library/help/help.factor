! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays hashtables io kernel namespaces ;

SYMBOL: last-block

: (help) ( topic -- )
    default-style [
        last-block on article-content print-element
    ] with-nesting* terpri ;

DEFER: $heading

: help ( topic -- )
    default-style [ dup article-title $heading ] with-style
    (help) ;

: glossary ( name -- ) <term> help ;

: handbook ( -- ) "handbook" help ;
    
: tutorial ( -- ) "tutorial" help ;

: articles. ( -- )
    
    ;
