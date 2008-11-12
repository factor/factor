USING: definitions io.launcher kernel parser words sequences math
math.parser namespaces editors make ;
IN: editors.emacs

: emacsclient ( file line -- )
    [
        \ emacsclient get ,
        "--no-wait" ,
        "+" swap number>string append ,
        ,
    ] { } make try-process ;

\ emacsclient "emacsclient" set-global

: emacs ( word -- )
    where first2 emacsclient ;

[ emacsclient ] edit-hook set-global

