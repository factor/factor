IN: help
USING: arrays gadgets-presentations io kernel namespaces parser
sequences words ;

: help ( topic -- )
    [
        dup article-title $heading terpri terpri
        article-content print-element terpri
    ] with-markup ;

: glossary ( name -- )
    <term> help ;

: HELP:
    scan-word
    [ >array reverse "help" set-word-prop ] ; parsing

: ARTICLE:
    [
        >array reverse [ first2 2 ] keep
        tail add-article
    ] ; parsing

[ word? ] "Show word documentation" [ help ] define-command
[ term? ] "Show term definition" [ help ] define-command
[ link? ] "Show article" [ help ] define-command

H{ } clone articles set
H{ } clone terms set
