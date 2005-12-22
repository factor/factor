IN: help
USING: arrays gadgets-listener gadgets-presentations hashtables
io kernel namespaces parser sequences words ;

: help ( topic -- )
    default-style [
        dup article-title $heading
        article-content print-element
        terpri*
    ] with-style ;

: glossary ( name -- ) <term> help ;

"Show word documentation" [ word? ] [ help ] \ in-browser define-command
"Show term definition" [ term? ] [ help ] \ in-browser define-default-command
"Show article" [ link? ] [ help ] \ in-browser define-default-command

H{ } clone articles set-global
H{ } clone terms set-global
