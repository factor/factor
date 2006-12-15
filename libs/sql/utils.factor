USING: arrays errors generic hashtables kernel math namespaces
prettyprint sequences sql strings tools words ;
IN: sql:utils

! : 2seq>hash 2array flip alist>hash ;

: 2seq>hash ( seq seq -- hash )
    H{ } clone -rot [ pick set-hash ] 2each ;

: tuple-fields ( tuple -- seq )
    class "slot-names" word-prop ;

: tuple>parts ( tuple -- values names )
    [ tuple-slots ] keep tuple-fields ;

: tuple>hash ( tuple -- hash )
    tuple>parts 2seq>hash ;

: tuple>all-slots
    delegates <reversed> V{ } clone
    [ tuple-slots dupd nappend ] reduce
    <reversed> prune <reversed> >array ;

: tuple>all-fields
    delegates <reversed> V{ } clone
    [ tuple-fields dupd nappend ] reduce
    <reversed> prune <reversed> >array ;
    
: full-tuple>hash ( tuple -- hash )
    delegates <reversed>
    H{ } clone [ tuple>hash hash-union ] reduce ;

: tuple>all-parts ( tuple -- values names )
    [
        [ full-tuple>hash ] keep tuple>all-fields
        [ swap hash ] map-with
    ] keep tuple>all-fields ;

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

GENERIC: escape-sql* ( string type db -- string )

M: connection escape-sql* ( string type db -- string )
    drop { "''" } "'" rot replace ;

: escape-sql ( string type -- string ) db get escape-sql* ;

: sanitize-name ( string -- string )
    "_p" "-?" pick subst ;

: tuple>sql-name ( tuple -- string )
    class unparse sanitize-name ;

: enquote% "'" % % "'" % ;

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
    >r dup clone r> append swap (each-last) ;

: (2each-last) ( seq seq quot quot -- )
    >r >r [ split-last ] 2apply swapd r> 2each r> 2each ; inline

: 2each-last ( seq seq quot quot -- )
    #! apply first quotation on all but last elt of seq
    #! apply second quotation on last element
    >r dup clone r> append swap (2each-last) ;

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
    [ sanitize-name % " " % % ] [ ", " % ] 2each-last ;

: tuple>mapping ( tuple -- string )
    [ tuple>mapping% ] "" make ;

: tuple>insert-parts ( tuple -- string )
    [
        tuple>parts
        [
            dup "id" = [
                2drop
            ] [
                over [ swap 2array , ] [ 2drop ] if
            ] if
        ] 2each
    ] { } make flip ;

: tuple>assignments% ( tuple -- string )
    [ tuple-slots [ maybe-unparse escape-sql ] map ] keep
    tuple-fields
    [ sanitize-name % " = " % enquote% ] [ ", " % ] 2each-last ;

: tuple>assignments% ( tuple -- string )
    tuple>parts dup [ "id" = ] find drop
    dup -1 = [ "tuple must have an id slot" throw ] when
    swap >r tuck >r remove-nth r> r> remove-nth
    >r [ maybe-unparse escape-sql ] map r>
    [ % " = " % enquote% ] [ ", " % ] 2each-last ;

: tuple>assignments ( tuple -- string )
    [ tuple>assignments% ] "" make ;

: tuple-slot ( string slot -- ? obj )
    "slot-names" over class word-props hash
    rot [ = ] curry find over -1 = [
        swap
    ] [
        drop 2 + swap tuple>array nth >r t r>
    ] if ;

: explode-tuple ( tuple -- )
    dup tuple-slots swap class "slot-names" word-prop
    [ set ] 2each ;


