USING: accessors assocs fry io.encodings.binary io.sockets kernel math
math.parser namespaces sequences splitting ;

IN: mongodb

! generic methods
GENERIC: store ( tuple/ht -- )
GENERIC: find ( example -- tuple/ht )
GENERIC: findOne ( exampe -- tuple/ht )
GENERIC: load ( object -- object ) 

USING: mongodb.msg mongodb.persistent mongodb.query mongodb.tuple 
mongodb.collection mongodb.connection ;

<PRIVATE

: prepare-find ( example -- query )
    [ mdb-collection>> get-collection-fqn ] keep
    H{ } tuple>query <mdb-query-msg> ; inline

PRIVATE>


: <mdb> ( db host port -- mdb )
    (<mdb>) ;



M: mdb-persistent store ( tuple --  )
    prepare-store ! H { collection { ... values ... } 
    [ [ <mdb-insert-msg> ] 2dip  
        [ get-collection-fqn >>collection ] dip
    objects>>
    [ mdb>> master>> binary ] dip '[ _ write-request ] with-client   
    ] assoc-each  ;

M: mdb-persistent find ( example -- result )
    prepare-find (find)
    build-result ;

M: mdb-persistent findOne ( example -- result )
    prepare-find (find-one)
    dup returned#>> 1 = 
    [ objects>> first ]
    [ drop f ] if ;

