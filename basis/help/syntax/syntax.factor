! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel parser sequences words help
help.topics namespaces vocabs definitions compiler.units
vocabs.parser ;
IN: help.syntax

: HELP:
    scan-word bootstrap-word
    dup set-word
    dup >link save-location
    \ ; parse-until >array swap set-word-help ; parsing

: ARTICLE:
    location [
        \ ; parse-until >array [ first2 ] keep 2 tail <article>
        over add-article >link
    ] dip remember-definition ; parsing

: ABOUT:
    in get vocab
    dup changed-definition
    scan-object >>help drop ; parsing
