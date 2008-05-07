USING: kernel parser sequences words ;
IN: unicode.syntax.backend

: VALUE:
    CREATE-WORD { f } clone [ first ] curry define ; parsing

: set-value ( value word -- )
    word-def first set-first ;
