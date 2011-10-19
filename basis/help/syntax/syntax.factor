! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.units definitions effects
effects.parser help help.topics kernel namespaces parser
sequences vocabs vocabs.parser words ;
IN: help.syntax

<PRIVATE

: check-effect ( word seq -- word seq' )
    dup ?first effect? [
        unclip pick stack-effect effect= [ bad-effect ] unless
    ] when ;

PRIVATE>

SYNTAX: HELP:
    scan-word bootstrap-word
    [ >link save-location ]
    [ \ ; parse-until check-effect >array swap set-word-help ]
    bi ;

SYNTAX: ARTICLE:
    location [
        \ ; parse-until >array [ first2 ] [ 2 tail ] bi <article>
        over add-article >link
    ] dip remember-definition ;

SYNTAX: ABOUT:
    current-vocab scan-object >>help changed-definition ;
