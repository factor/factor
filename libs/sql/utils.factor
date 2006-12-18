USING: arrays errors generic hashtables kernel kernel-internals
math namespaces parser prettyprint sequences sql
strings tools words ;
IN: sql:utils

: sanitize ( string -- string )
    "_p" "-?" pick subst ;

: obj>string/f ( obj -- string/f )
   dup [ dup string? [ unparse ] unless ] when ;

: bottom-delegate ( tuple -- tuple/f )
    dup delegate [ nip bottom-delegate ] when* ;

: set-bottom-delegate ( delegate tuple -- )
    bottom-delegate set-delegate ;

: make-persistent ( id tuple -- )
    >r <persistent> r> set-bottom-delegate ;

: remove-bottom-delegate ( tuple -- )
    dup delegate [
        delegate [
            delegate remove-bottom-delegate
        ] [
            f swap set-delegate
        ] if
    ] [
        drop
    ] if* ;

: make-empty-tuple ( string -- tuple )
    parse call dup tuple-size <tuple> ;

: field>sqlite-bind-name ( string -- string )
    >r ":" r> append sanitize ;

: tuple-slot ( string tuple -- ? obj )
    "slot-names" over class word-props hash
    pick [ = ] curry find over -1 = [
        2drop delegate dup [ tuple-slot ] [ 2drop f -1 ] if
    ] [
        drop rot drop 2 + swap tuple>array nth >r t r>
    ] if ;

: tuple-fields ( tuple -- seq )
    class "slot-names" word-prop ;

: tuple>parts ( tuple -- values names )
    [ tuple-slots ] keep tuple-fields ;

: tuple>alist ( tuple -- alist )
    tuple>parts [ swap 2array ] 2map ;

: full-tuple>fields ( tuple -- seq )
    delegates <reversed> V{ } clone
    [ tuple-fields dupd nappend ] reduce
    <reversed> prune <reversed> >array ;

: full-tuple>slots ( tuple -- seq )
    dup full-tuple>fields [ swap tuple-slot nip ] map-with ;

: full-tuple>parts ( tuple -- values names )
    [ full-tuple>slots ] keep full-tuple>fields ;

: full-tuple>alist ( tuple -- alist )
    full-tuple>parts [ swap 2array ] 2map ;

: alist-remove-key ( alist key -- seq )
    [ >r first r> = not ] curry subset ;

: alist-remove-value ( alist value -- seq )
    [ >r second r> = not ] curry subset ;

: alist-key-each ( alist quot -- )
    [ first ] swap append each ;

: tuple>insert-alist ( tuple -- alist )
    full-tuple>alist
    "id" alist-remove-key
    f alist-remove-value ;

: tuple>update-alist ( tuple -- alist )
    full-tuple>alist "id" over assoc
    >r "rowid" r> 2array 1array append 
    "id" alist-remove-key ;

: tuple>delete-alist ( tuple -- alist )
    >r "rowid" r> "id" swap tuple-slot nip 2array 1array ;

: tuple>select-alist ( tuple -- alist )
    full-tuple>alist
    f alist-remove-value ;

! : 2seq>hash 2array flip alist>hash ;

: 2seq>hash ( seq seq -- hash )
    H{ } clone -rot [ pick set-hash ] 2each ;


: tuple>hash ( tuple -- hash ) tuple>parts 2seq>hash ;
    
: full-tuple>hash ( tuple -- hash )
    delegates <reversed>
    H{ } clone [ tuple>hash hash-union ] reduce ;

: maybe-unparse ( obj -- )
    dup string? [ unparse ] unless ;

: replace ( new old seq -- seq )
    >r 2seq>hash r> [
        [
            [
                tuck swap hash* [ nip ] [ drop ] if
                dup sequence? [ % ] [ , ] if 
            ] each-with
        ] { } make
    ] keep like ;

GENERIC: escape-sql* ( string db -- string )

M: connection escape-sql* ( string db -- string )
    drop dup string? [
        { "''" } "'" rot replace
    ] when ;

: escape-sql ( string -- string ) db get escape-sql* ;

: tuple>sql-name ( tuple -- string )
    class unparse sanitize ;

: tuple>sql-name% ( tuple -- string )
    tuple>sql-name % ;


: enquote% "'" % dup string? [ unparse ] unless % "'" % ;

: enquote ( string -- 'string' )
    [ enquote% ] "" make ;

: split-last ( seq -- last most )
    dup length {
        { [ dup zero? ] [ 2drop f f ] }
        { [ dup 1 = ] [ drop f ] }
        { [ t ] [ >r [ peek 1array ] keep r> 1- head ] }
    } cond ;

: (each-last) ( seq quot quot -- )
    >r >r split-last r> each r> each ; inline

: each-last ( seq quot quot -- )
    >r dup clone r> append swap (each-last) ; inline

: (2each-last) ( seq seq quot quot -- )
    >r >r [ split-last ] 2apply swapd r> 2each r> 2each ; inline

: 2each-last ( seq seq quot quot -- )
    #! apply first quotation on all but last elt of seq
    #! apply second quotation on last element
    >r dup clone r> append swap (2each-last) ; inline

! <foo1> { integer string }
! mapping: { integer { varchar(256) "not null" } }
! { "a integer" "b string" }

SYMBOL: mappings
H{ } clone mappings set-global

: get-mapping ( tuple -- seq )
    dup class mappings get hash* [
        nip
    ] [
        drop tuple-slots [ drop "varchar" ] map
    ] if ;

: tuple>mapping% ( obj -- seq )
    [ get-mapping ] keep tuple-fields
    [ sanitize % " " % % ] [ ", " % ] 2each-last ;

: tuple>mapping ( tuple -- string )
    [ tuple>mapping% ] "" make ;


: explode-tuple ( tuple -- )
    dup tuple-slots swap class "slot-names" word-prop
    [ set ] 2each ;



