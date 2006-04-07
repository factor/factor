IN: inference
USING: hashtables kernel math namespaces sequences ;

TUPLE: shuffle in-d in-r out-d out-r ;

: load-shuffle ( d r shuffle -- )
    tuck shuffle-in-r [ set ] 2each shuffle-in-d [ set ] 2each ;

: shuffled-values ( values -- values )
    [ [ namespace hash dup ] keep ? ] map ;

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
    over shuffle-out-d over shuffle-in-d [ length ] 2apply < [
        over shuffle-out-d length over shuffle-in-d head*
        [ pick shuffle-in-d append pick set-shuffle-in-d ] keep
        pick shuffle-out-d append pick set-shuffle-out-d
    ] when 2drop ;

: fix-compose-r ( s1 s2 -- )
    over shuffle-out-r over shuffle-in-r [ length ] 2apply < [
        over shuffle-out-r length over shuffle-in-r head*
        [ pick shuffle-in-r append pick set-shuffle-in-r ] keep
        pick shuffle-out-r append pick set-shuffle-out-r
    ] when 2drop ;

: compose-shuffle ( s1 s2 -- s1+s2 )
    #! s1's d and r output lengths must be at least the required
    #! length for the shuffle. If they are not, a special
    #! behavior is used which is only valid for the optimizer.
    [ clone ] 2apply 2dup fix-compose-d 2dup fix-compose-r
    >r dup shuffle-out-d over shuffle-out-r r> shuffle
    >r >r dup shuffle-in-d swap shuffle-in-r r> r> <shuffle> ;

M: shuffle clone ( shuffle -- shuffle )
    [ shuffle-in-d clone ] keep
    [ shuffle-in-r clone ] keep
    [ shuffle-out-d clone ] keep
    shuffle-out-r clone
    <shuffle> ;

SYMBOL: live-d
SYMBOL: live-r

: value-dropped? ( value -- ? )
    dup value?
    over live-d get member? not
    rot live-r get member? not and
    or ;

: filter-dropped ( seq -- seq )
    [ dup value-dropped? [ drop f ] when ] map ;

: live-stores ( instack outstack -- stack )
    #! Avoid storing a value into its former position.
    dup length [ pick ?nth dupd eq? [ drop f ] when ] 2map nip ;

: trim-shuffle ( shuffle -- shuffle )
    dup shuffle-in-d over shuffle-out-d live-stores live-d set
    dup shuffle-in-r over shuffle-out-r live-stores live-r set
    dup shuffle-in-d filter-dropped
    swap shuffle-in-r filter-dropped
    live-d get live-r get <shuffle> ;
