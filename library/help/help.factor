IN: help
USING: arrays gadgets-presentations hashtables io kernel
namespaces parser sequences words ;

: help ( topic -- )
    default-style [
        dup article-title $heading
        article-content print-element
        terpri*
    ] with-style ;

: glossary ( name -- ) <term> help ;

"Show word documentation" [ word? ] [ help ] define-command
"Show term definition" [ term? ] [ help ] define-default-command
"Show article" [ link? ] [ help ] define-default-command

H{ } clone articles global set-hash
H{ } clone terms global set-hash
