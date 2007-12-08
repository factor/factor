
USING: kernel sequences arrays vectors namespaces math strings
    combinators continuations quotations io assocs ;

IN: prolog

SYMBOL: pldb
SYMBOL: plchoice

: init-pl ( -- ) V{ } clone pldb set V{ } clone plchoice set ;

: reset-choice ( -- ) V{ } clone plchoice set ;
: remove-choice ( -- ) plchoice get pop drop ;
: add-choice ( continuation -- ) 
    dup continuation? [ plchoice get push ] [ drop ] if ;
: last-choice ( -- ) plchoice get pop continue ;

: rules ( -- vector ) pldb get ;
: rule ( n -- rule ) dup rules length >= [ drop "No." ] [ rules nth ] if ;

: var? ( pl-obj -- ? ) 
    dup string? [ 0 swap nth LETTER? ] [ drop f ] if ;
: const? ( pl-obj -- ? ) var? not ;

: check-arity ( pat fact -- pattern fact ? ) 2dup [ length ] 2apply = ;
: check-elements ( pat fact -- ? ) [ over var? [ 2drop t ] [ = ] if ] 2all? ;
: (double-bound) ( key value assoc -- ? )
    pick over at* [ pick = >r 3drop r> ] [ drop swapd set-at t ] if ;
: single-bound? ( pat-d pat-f -- ? ) 
    H{ } clone [ (double-bound) ] curry 2all? ;
: match-pattern ( pat fact -- ? ) 
    check-arity [ 2dup check-elements -rot single-bound? and ] [ 2drop f ] if ;
: good-result? ( pat fact -- pat fact ? )
    2dup dup "No." = [ 2drop t ] [ match-pattern ] if ;

: add-rule ( name pat body -- ) 3array rules dup length swap set-nth ;

: (lookup-rule) ( name num -- pat-f rules )
    dup rule dup "No." = >r 0 swap nth swapd dupd = swapd r> or 
    [ dup rule [ ] callcc0 add-choice ] when
    dup number? [ 1+ (lookup-rule) ] [ 2nip ] if ;

: add-bindings ( pat-d pat-f binds -- binds )
    clone
    [ over var? over const? or 
        [ 2drop ] [ rot dup >r set-at r> ] if 
    ] 2reduce ;
: init-binds ( pat-d pat-f -- binds ) V{ } clone add-bindings >alist ;

: replace-if-bound ( binds elt -- binds elt' ) 
    over 2dup key? [ at ] [ drop ] if ;
: deep-replace ( binds seq -- binds seq' )
    [ dup var? [ replace-if-bound ] 
        [ dup array? [ dupd deep-replace nip ] when ] if 
    ] map ;

: backtrace? ( result -- )
    dup "No." = [ remove-choice last-choice ] 
    [ [ last-choice ] unless ] if ;

: resolve-rule ( pat-d pat-f rule-body -- binds )
    >r 2dup init-binds r> [ deep-replace >quotation call dup backtrace?
    dup t = [ drop ] when ] each ;

: rule>pattern ( rule -- pattern ) 1 swap nth ;
: rule>body ( rule -- body ) 2 swap nth ;

: binds>fact ( pat-d pat-f binds -- fact )
    [ 2dup key? [ at ] [ drop ] if ] curry map good-result? 
    [ nip ] [ last-choice ] if ;

: lookup-rule ( name pat -- fact )
    swap 0 (lookup-rule) dup "No." =
    [ nip ]
    [ dup rule>pattern swapd check-arity 
        [ rot rule>body resolve-rule dup -roll binds>fact nip ] [ last-choice ] if
    ] if ;

: binding-resolve ( binds name pat -- binds )
    tuck lookup-rule dup backtrace? swap rot add-bindings ;

: is ( binds val var -- binds ) rot [ set-at ] keep ;
