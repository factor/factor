USING: kernel math sequences strings ;
IN: sequences.trim

: (rtrim*) ( seq quot -- newseq )
    over length 0 > [
        2dup >r peek r> call
        [ >r dup length 1- head-slice r> (rtrim*) ] [ drop ] if
    ] [
        drop
    ] if ;
: rtrim* ( seq quot -- newseq ) [ (rtrim*) ] 2keep drop like ;
: rtrim ( seq -- newseq ) [ blank? ] rtrim* ;

: (ltrim*) ( seq quot -- newseq )
    over length 0 > [
        2dup >r first r> call [ >r 1 tail-slice r> (ltrim*) ] [ drop ] if
    ] [
        drop
    ] if ;
: ltrim* ( seq quot -- newseq ) [ (ltrim*) ] 2keep drop like ;
: ltrim ( seq -- newseq ) [ blank? ] ltrim* ;

: trim* ( seq quot -- newseq ) [ (ltrim*) ] keep rtrim* ;
: trim ( seq -- newseq ) [ blank? ] trim* ;

