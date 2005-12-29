IN: help
USING: arrays gadgets-listener gadgets-presentations hashtables
io kernel namespaces parser sequences words ;

: (help) ( topic -- )
    default-style [
        article-content print-element terpri*
    ] with-style ;

DEFER: $heading

: help ( topic -- )
    dup article-title $heading (help) ;

: glossary ( name -- ) <term> help ;
