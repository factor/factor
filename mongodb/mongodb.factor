USING: accessors assocs fry io.encodings.binary io.sockets kernel math
math.parser namespaces sequences splitting
mongodb.connection mongodb.persistent mongodb.msg mongodb.query
mongodb.tuple ;

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

PRIVATE>


: <mdb> ( db host port -- mdb )
    (<mdb>) ;

M: mdb-persistent store ( tuple --  )
    prepare-store ! H { collection { ... values ... } 
    [ [ get-collection-fqn ] dip
      values <mdb-insert-msg>      
      [ mdb>> master>> binary ] dip '[ _ write-message ] with-client   
    ] assoc-each  ;

M: mdb-persistent find ( example -- result )
    prepare-find [ mdb>> master>> ] dip (find)
    build-result ;

M: mdb-persistent nfind ( example n -- result )
    [ prepare-find ] dip >>return#
    [ mdb>> master>> ] dip (find)
    build-result ;

M: mdb-persistent explain ( example -- result )
    prepare-find [ query>> [ t "$explain" ] dip  set-at ] keep
    [ mdb>> master>> ] dip (find-one)
    build-result ; 
