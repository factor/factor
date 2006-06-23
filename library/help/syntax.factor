! Copyright (C) 2005 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: !syntax
USING: arrays help kernel parser sequences syntax words ;

: !HELP:
    scan-word bootstrap-word dup [
        >array unclip swap
        >r "stack-effect" set-word-prop r>
        set-word-help
    ] f ; parsing

: !ARTICLE:
    [ >array [ first2 2 ] keep tail add-article ] f ; parsing
