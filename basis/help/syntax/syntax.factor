! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.units definitions help
help.topics kernel math parser sequences vocabs.parser words ;
IN: help.syntax

SYNTAX: HELP:
    scan-word bootstrap-word
    [ >link save-location ]
    [ [ parse-array-def ] dip set-word-help ]
    bi ;

ERROR: article-expects-name-and-title got ;

SYNTAX: ARTICLE:
    location [
        parse-array-def
        dup length 2 < [ article-expects-name-and-title ] when
        [ first2 ] [ 2 tail ] bi <article>
        over add-article >link
    ] dip remember-definition ;

SYNTAX: ABOUT:
    current-vocab scan-object >>help changed-definition ;
