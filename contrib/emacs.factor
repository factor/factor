REQUIRES: contrib/process ;

USING: definitions kernel parser words sequences math process
namespaces ;

IN: emacs

: emacsclient ( file line -- )
number>string "emacsclient --no-wait +" swap append " " rot append3 system ;

: emacs ( word -- )
where first2 emacsclient ;

[ emacsclient ] edit-hook set-global

PROVIDE: contrib/emacs ;
