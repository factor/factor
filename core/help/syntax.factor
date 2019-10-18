! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: !syntax
USING: arrays help kernel parser sequences syntax words ;

: !HELP:
    scan-word bootstrap-word dup set-word
    dup location "help-loc" set-word-prop
    \ ; parse-until >array swap set-word-help ; parsing

: !ARTICLE:
    location >r
    \ ; parse-until >array [ first2 ] keep 2 tail
    r> <article>
    swap add-article ; parsing
