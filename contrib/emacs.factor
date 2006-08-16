
REQUIRES: process ;

USING: kernel parser words sequences math process ;

IN: emacs

: emacsclient ( file line -- )
number>string "emacsclient --no-wait +" swap append " " rot append3 system ;

: emacs ( word -- )
dup word-file swap "line" word-prop emacsclient ;

PROVIDE: emacs ;