! Copyright (C) 2005 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: !syntax
USING: arrays help kernel parser sequences syntax words ;

: !HELP:
    scan-word bootstrap-word dup set-word
    dup location "help-loc" set-word-prop
    [ >array set-word-help ] f ; parsing

: !ARTICLE:
    location
    [
        swap >r >array [ first2 ] keep 2 tail r> <article>
        add-article
    ]
    f ; parsing
