USING: accessors assocs combinators fry io.encodings.binary
io.sockets kernel math math.parser mongodb.driver
mongodb.msg mongodb.operations mongodb.persistent
mongodb.tuple namespaces
sequences splitting ;

IN: mongodb

! generic methods
GENERIC: store ( tuple/ht -- )
GENERIC: find ( example -- tuple/ht )
GENERIC# nfind 1 ( example n -- tuple/ht )
GENERIC: load ( object -- object )
GENERIC: explain ( object -- object )

<PRIVATE

: prepare-find ( example -- query )
    [ mdb-collection>> get-collection-fqn ] keep
    H{ } tuple>query <mdb-query-msg> ; inline

TUPLE: mdb-result { cursor integer }
{ start# integer }
{ returned# integer }
{ objects sequence } ;

: build-result ( resultmsg -- mdb-result )
    [ mdb-result new ] dip
    {
        [ cursor>> >>cursor ]
        [ start#>> >>start# ]
        [ returned#>> >>returned# ]
        [ objects>> [ assoc>tuple ] map >>objects ]
    } cleave ;

PRIVATE>

M: mdb-persistent store ( tuple --  )
    prepare-store ! H { collection { ... values ... } 
    [ [ get-collection-fqn ] dip
      values <mdb-insert-msg> send-message     
    ] assoc-each  ;

M: mdb-persistent find ( example -- result )
    prepare-find [ mdb>> master>> ] dip send-query
    build-result ;

M: mdb-persistent nfind ( example n -- result )
    [ prepare-find ] dip >>return#
    send-query build-result ;
