REQUIRES: libs/process ;

USING: definitions kernel parser words sequences math process
namespaces ;

IN: emacs

: emacsclient ( file line -- )
[ "emacsclient --no-wait +" % # " " % % ] "" make system drop ;

: emacs ( word -- )
where first2 emacsclient ;

[ emacsclient ] edit-hook set-global

PROVIDE: libs/emacs ;
