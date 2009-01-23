USING: accessors assocs fry io.encodings.binary io.sockets kernel math
math.parser mongodb.msg mongodb.persistent mongodb.query mongodb.tuple
namespaces sequences splitting ;

IN: mongodb

INTERSECTION: storable mdb-persistent ;

<PRIVATE


: prepare-find ( example -- query )
    [ mdb-collection>> get-collection-fqn ] keep
    H{ } tuple>query <mdb-query-msg> ; inline

PRIVATE>


: <mdb> ( db host port -- mdb )
    (<mdb>) ;


GENERIC: store ( tuple/ht -- )

GENERIC: find ( example -- tuple/ht )

GENERIC: findOne ( exampe -- tuple/ht )

GENERIC: load ( object -- object ) 


M: storable store ( tuple --  )
    prepare-store ! H { collection { ... values ... } 
    [ [ <mdb-insert-msg> ] 2dip  
        [ get-collection-fqn >>collection ] dip
    objects>>
    [ mdb>> master>> binary ] dip '[ _ write-request ] with-client   
    ] assoc-each  ;

M: storable find ( example -- result )
    prepare-find (find)
    build-result ;

M: storable findOne ( example -- result )
    prepare-find (find-one)
    dup returned#>> 1 = 
    [ objects>> first ]
    [ drop f ] if ;

