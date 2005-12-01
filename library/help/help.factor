IN: help
USING: arrays gadgets-presentations hashtables io kernel
namespaces parser sequences words ;

: help ( topic -- )
    [
        dup article-title $heading terpri terpri
        article-content print-element terpri
    ] with-markup ;

: glossary ( name -- ) <term> help ;

: HELP:
    scan-word [ >array "help" set-word-prop ] [ ] ; parsing

: ARTICLE:
    [ >array [ first2 2 ] keep tail add-article ] [ ] ; parsing

: GLOSSARY:
    [ >array [ first 1 ] keep tail add-term ] [ ] ; parsing

[ word? ] "Show word documentation" [ help ] define-command
[ term? ] "Show term definition" [ help ] define-command
[ link? ] "Show article" [ help ] define-command

H{ } clone articles global set-hash
H{ } clone terms global set-hash
