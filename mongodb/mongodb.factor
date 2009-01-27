USING: accessors assocs fry io.encodings.binary io.sockets kernel math
math.parser namespaces sequences splitting
mongodb.connection mongodb.persistent mongodb.msg mongodb.query
mongodb.tuple ;

IN: mongodb

! generic methods
GENERIC: store ( tuple/ht -- )
GENERIC: find ( example -- tuple/ht )
GENERIC: findOne ( exampe -- tuple/ht )
GENERIC: load ( object -- object ) 

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
      [ mdb>> master>> binary ] dip '[ _ write-request ] with-client   
    ] assoc-each  ;

M: mdb-persistent find ( example -- result )
    prepare-find [ mdb>> master>> ] dip (find)
    build-result ;

M: mdb-persistent findOne ( example -- result )
    prepare-find [ mdb>> master>> ] dip (find-one)
    dup returned#>> 1 = 
    [ objects>> first ]
    [ drop f ] if ;

