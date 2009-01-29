USING: accessors combinators fry io.encodings.binary io.sockets kernel
mongodb.msg mongodb.persistent mongodb.connection sequences math namespaces assocs
formatting splitting mongodb.tuple mongodb.index ;

IN: mongodb.query

TUPLE: mdb-result { cursor integer }
{ start# integer }
{ returned# integer }
{ objects sequence } ;

: namespaces-ns ( name -- ns )
     "%s.system.namespaces" sprintf ; inline

<PRIVATE

: (execute-query) ( inet quot -- result )
     [ binary ] dip with-client ; inline

PRIVATE>

: (find) ( inet query -- result )
     '[ _ write-message read-message ] (execute-query) ; inline

: (find-one) ( inet query -- result )
    1 >>return#
    (find) ; inline

: build-result ( resultmsg -- mdb-result )
    [ mdb-result new ] dip
    {
        [ cursor>> >>cursor ]
        [ start#>> >>start# ]
        [ returned#>> >>returned# ]
        [ objects>> [ assoc>tuple ] map >>objects ]
    } cleave ;

: load-collections ( -- collections )
    mdb>> [ master>> ] [ name>> namespaces-ns ] bi
    H{ } clone <mdb-query-msg> (find)
    objects>> [ [ "name" ] dip at "." split second <mdb-collection> ] map
    H{ } clone tuck
    '[ [ ensure-indices ] [ ] [ name>> ] tri _ set-at  ] each 
        [ mdb>> ] dip >>collections collections>> ;
    
: check-ok ( result -- ? )
     [ "ok" ] dip key? ; inline 

: create-collection ( mdb-collection --  )
     dup name>> "create" H{ } clone [ set-at ] keep 
     [ mdb>> [ master>> ] [ name>> ] bi "%s.$cmd" sprintf ] dip
     <mdb-query-msg> (find-one) objects>> first
     check-ok
     [ [ ensure-indices ] keep dup name>> mdb>> collections>> set-at ]
     [ "could not create collection" throw ] if ; 

: get-collection-fqn ( mdb-collection -- fqdn )
     mdb>> collections>>
     dup keys length 0 =
     [ drop load-collections ]
     [ ] if
     [ dup name>> ] dip
     key?
     [ ]
     [ dup create-collection ] if
     name>> [ mdb>> name>> ] dip "%s.%s" sprintf ;

 