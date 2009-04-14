! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel parser sequences words help
help.topics namespaces vocabs definitions compiler.units
vocabs.parser ;
IN: help.syntax

SYNTAX: HELP:
    scan-word bootstrap-word
    [ >link save-location ] [ [ \ ; parse-until >array ] dip set-word-help ] bi ;

SYNTAX: ARTICLE:
    location [
        \ ; parse-until >array [ first2 ] [ 2 tail ] bi <article>
        over add-article >link
    ] dip remember-definition ;

SYNTAX: ABOUT:
    in get vocab scan-object >>help changed-definition ;
