IN: inference
USING: kernel math namespaces sequences ;

TUPLE: shuffle in-d in-r out-d out-r ;

: empty-shuffle { } { } { } { } <shuffle> ;

: cut* ( seq1 seq2 -- seq seq ) [ head* ] 2keep tail* ;

: load-shuffle ( d r shuffle -- )
    tuck shuffle-in-r [ set ] 2each shuffle-in-d [ set ] 2each ;

: shuffled-values ( values -- values )
    [ dup literal? [ get ] unless ] map ;

: store-shuffle ( shuffle -- d r )
    dup shuffle-out-d shuffled-values
    swap shuffle-out-r shuffled-values ;

: shuffle* ( d r shuffle -- d r )
    [ [ load-shuffle ] keep store-shuffle ] with-scope ;

: split-shuffle ( d r shuffle -- d' r' d r )
    tuck shuffle-in-r length swap cut*
    >r >r shuffle-in-d length swap cut*
    r> swap r> ;

: join-shuffle ( d' r' d r -- d r )
    swapd append >r append r> ;

: shuffle ( d r shuffle -- d r )
    #! d and r lengths must be at least the required length for
    #! the shuffle.
    [ split-shuffle ] keep shuffle* join-shuffle ;

: fix-compose-d ( s1 s2 -- )
    over shuffle-out-d over shuffle-in-d length< [
        over shuffle-out-d length over shuffle-in-d head*
        [ pick shuffle-in-d append pick set-shuffle-in-d ] keep
        pick shuffle-out-d append pick set-shuffle-out-d
    ] when 2drop ;

: fix-compose-r ( s1 s2 -- )
    over shuffle-out-r over shuffle-in-r length< [
        over shuffle-out-r length over shuffle-in-r head*
        [ pick shuffle-in-r append pick set-shuffle-in-r ] keep
        pick shuffle-out-r append pick set-shuffle-out-r
    ] when 2drop ;

: compose-shuffle ( s1 s2 -- s1+s2 )
    #! s1's d and r output lengths must be at least the required
    #! length for the shuffle. If they are not, a special
    #! behavior is used which is only valid for the optimizer.
    >r clone r> clone 2dup fix-compose-d 2dup fix-compose-r
    >r dup shuffle-out-d over shuffle-out-r r> shuffle
    >r >r dup shuffle-in-d swap shuffle-in-r r> r> <shuffle> ;

M: shuffle clone ( shuffle -- shuffle )
    [ shuffle-in-d clone ] keep
    [ shuffle-in-r clone ] keep
    [ shuffle-out-d clone ] keep
    shuffle-out-r clone
    <shuffle> ;
