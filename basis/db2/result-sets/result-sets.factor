! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db2.binders db2.connections
db2.types
destructors fry kernel namespaces sequences ;
IN: db2.result-sets

TUPLE: result-set handle sql in out n max ;

GENERIC: #rows ( result-set -- n )
GENERIC: #columns ( result-set -- n )
GENERIC: advance-row ( result-set -- )
GENERIC: more-rows? ( result-set -- ? )
GENERIC#: column 2 ( result-set column type -- sql )
GENERIC: get-type ( binder/word -- type )
HOOK: statement>result-set db-connection ( statement -- result-set )

: init-result-set ( result-set -- result-set )
    dup #rows >>max
    0 >>n ; inline

: new-result-set ( query handle class -- result-set )
    new
        swap >>handle
        swap {
            [ sql>> >>sql ]
            [ in>> >>in ]
            [ out>> >>out ]
        } cleave ; inline

ERROR: result-set-length-mismatch result-set #columns out-length ;

: validate-result-set ( result-set -- result-set )
    dup [ #columns ] [ out>> length ] bi 2dup = [
        2drop
    ] [
        result-set-length-mismatch
    ] if ;

: sql-row ( result-set -- seq )
    [ #columns <iota> ] [ out>> ] [ ] tri over empty? [
        nip
        '[ [ _ ] dip VARCHAR column ] map
    ] [
        validate-result-set
        '[ [ _ ] 2dip get-type column ] 2map
    ] if ;

M: sql-type get-type ;

M: out-binder get-type type>> ;

M: out-binder-low get-type type>> ;

: result-set-each ( statement quot: ( statement -- ) -- )
    over more-rows?
    [ [ call ] 2keep over advance-row result-set-each ]
    [ 2drop ] if ; inline recursive

: result-set-map ( statement quot -- sequence )
    collector [ result-set-each ] dip { } like ; inline

: statement>result-sequence ( statement -- sequence )
    statement>result-set
    [ [ sql-row ] result-set-map ] with-disposal ;
