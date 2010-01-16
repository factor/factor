USING: accessors http.server http.server.filters io.pools kernel
mongodb.driver mongodb.connection namespaces ;

IN: furnace.mongodb

TUPLE: mdb-persistence < filter-responder pool ;

: <mdb-persistence> ( responder mdb -- responder' )
    <mdb-pool> mdb-persistence boa ;

M: mdb-persistence call-responder*
    dup pool>> [ mdb-connection set call-next-method ] with-pooled-connection ;
