USING: definitions io.launcher kernel parser words sequences math
math.parser namespaces editors make system combinators.short-circuit
fry threads ;
IN: editors.emacs

SYMBOL: emacsclient-path

HOOK: default-emacsclient os ( -- path )

M: object default-emacsclient ( -- path ) "emacsclient" ;

: emacsclient ( file line -- )
    [
        { [ \ emacsclient-path get ] [ default-emacsclient ] } 0|| ,
        "--no-wait" ,
        number>string "+" prepend ,
        ,
    ] { } make run-detached drop ;

: emacs ( word -- )
    where first2 emacsclient ;

[ emacsclient ] edit-hook set-global
