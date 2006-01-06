IN: help
USING: arrays hashtables io kernel ;

: (help) ( topic -- )
    default-style [
        [ article-content print-element ] with-nesting* terpri*
    ] with-style ;

DEFER: $heading

: help ( topic -- )
    dup article-title $heading (help) ;

: glossary ( name -- ) <term> help ;
