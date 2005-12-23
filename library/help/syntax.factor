IN: !syntax
USING: arrays help kernel parser sequences syntax words ;

: HELP:
    scan-word [ >array "help" set-word-prop ] [ ] ; parsing

: ARTICLE:
    [ >array [ first2 2 ] keep tail add-article ] [ ] ; parsing

: GLOSSARY:
    [ >array [ first 1 ] keep tail add-term ] [ ] ; parsing
