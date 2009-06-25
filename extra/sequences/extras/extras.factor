USING: arrays kernel locals math sequences ;
IN: sequences.extras
: reduce1 ( seq quot -- result ) [ unclip ] dip reduce ; inline

:: reduce-r
    ( list identity quot: ( obj1 obj2 -- obj ) -- result )
    list empty?
    [ identity ]
    [ list rest identity quot reduce-r list first quot call ] if ;
    inline recursive

! Quot must have static stack effect, unlike "reduce"
:: reduce* ( seq id quot -- result ) seq
    [ id ]
    [ unclip id swap quot call( prev elt -- next ) quot reduce* ] if-empty ; inline recursive

:: combos ( list1 list2 -- result ) list2 [ [ 2array ] curry list1 swap map ] map concat ;
: (head-slice) ( seq n -- seq' ) over length over < [ drop ] [ head-slice ] if ;
: find-all ( seq quot -- elts ) [ [ length iota ] keep ] dip
    [ dupd call( a -- ? ) [ 2array ] [ 2drop f ] if ] curry 2map [ ] filter ; inline

: empty ( seq -- ) 0 swap shorten ;