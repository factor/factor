! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: words assocs kernel accessors parser sequences summary
lexer splitting fry combinators ;
IN: xml.dispatch

TUPLE: no-tag name word ;
M: no-tag summary
    drop "The tag-dispatching word has no method for the given tag name" ;

: compile-tags ( word xtable -- quot )
    >alist swap '[ _ no-tag boa throw ] suffix
    '[ dup main>> _ case ] ;

: define-tags ( word -- )
    dup dup "xtable" word-prop compile-tags define ;

: define-tag ( string word quot -- )
    -rot [ "xtable" word-prop set-at ] [ define-tags ] bi ;

:: define-tag ( string word quot -- )
    quot string word "xtable" word-prop set-at
    word define-tags ;

: TAGS:
    CREATE
    [ H{ } clone "xtable" set-word-prop ]
    [ define-tags ] bi ; parsing

: TAG:
    scan scan-word parse-definition define-tag ; parsing
