USING: definitions io.launcher kernel parser words sequences math
math.parser namespaces editors make system ;
IN: editors.emacs

: emacsclient ( file line -- )
    [
        \ emacsclient get "emacsclient" or ,
        os windows? [ "--no-wait" , ] unless
        "+" swap number>string append ,
        ,
    ] { } make try-process ;

: emacs ( word -- )
    where first2 emacsclient ;

[ emacsclient ] edit-hook set-global

