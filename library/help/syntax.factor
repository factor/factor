! Copyright (C) 2005 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: !syntax
USING: arrays help kernel parser sequences syntax words ;

: HELP:
    scan-word bootstrap-word dup [
        >array uncons* >r "stack-effect" set-word-prop r>
        "help" set-word-prop
    ] [ ] ; parsing

: ARTICLE:
    [ >array [ first2 2 ] keep tail add-article ] [ ] ; parsing

: GLOSSARY:
    [ >array [ first 1 ] keep tail add-term ] [ ] ; parsing
