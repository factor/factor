USING: accessors combinators fry io.encodings.binary io.sockets kernel
mongodb.msg mongodb.persistent sequences math namespaces assocs
formatting ;

IN: mongodb.query

TUPLE: mdb-node master? inet ;

TUPLE: mdb name nodes collections ;

: mdb>> ( -- mdb )
    mdb get ; inline

: with-db ( mdb quot -- * )
    '[ _ mdb set _ call ] with-scope ; inline

: master>> ( mdb -- inet )
    nodes>> [ t ] dip at ;

: slave>> ( mdb -- inet )
    nodes>> [ f ] dip at ;

TUPLE: mdb-result { cursor integer }
{ start# integer }
{ returned# integer }
{ objects sequence } ;

: index-ns ( -- ns )
    mdb>> name>> "%s.system.indexes" sprintf ; inline

: namespaces-ns ( -- ns )
    mdb>> name>> "%s.system.namespaces" sprintf ; inline
    
<PRIVATE

: (execute-query) ( inet quot -- result )
    [ binary ] dip with-client ; inline

PRIVATE>

: (find-raw) ( inet query -- result )
    '[ _ write-request read-reply ] (execute-query) ; inline

: (find-one-raw) ( inet query -- result )
    (find-raw) objects>> first ; inline

: (find) ( query -- result )
    [ mdb>> master>> ] dip (find-raw) ;

: (find-one) ( query -- result )
    [ mdb>> master>> ] dip (find-one-raw) ;

: build-result ( resultmsg -- mdb-result )
    [ mdb-result new ] dip
    {
        [ cursor>> >>cursor ]
        [ start#>> >>start# ]
        [ returned#>> >>returned# ]
        [ objects>> [ assoc>tuple ] map >>objects ]
    } cleave ;

: query-collections ( -- result )
    namespaces-ns H{ } clone <mdb-query-msg> (find) ;

