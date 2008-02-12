USING: definitions io.launcher kernel parser words sequences math
math.parser namespaces editors ;
IN: editors.emacs

: emacsclient ( file line -- )
    [
        "emacsclient" ,
        "--no-wait" ,
        "+" swap number>string append ,
        ,
    ] { } make try-process ;

: emacs ( word -- )
    where first2 emacsclient ;

[ emacsclient ] edit-hook set-global

