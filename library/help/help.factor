IN: help
USING: arrays gadgets-presentations hashtables io kernel
namespaces parser sequences words ;

: help ( topic -- )
    [
        dup article-title $heading terpri terpri
        article-content print-element terpri
    ] with-markup ;

: glossary ( name -- ) <term> help ;

"Show word documentation" [ word? ] [ help ] define-command
"Show term definition" [ term? ] [ help ] define-command
"Show article" [ link? ] [ help ] define-command

H{ } clone articles global set-hash
H{ } clone terms global set-hash
