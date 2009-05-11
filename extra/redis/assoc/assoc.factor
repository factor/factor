! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs io.encodings.8-bit io.sockets
io.streams.duplex kernel redis sequences ;
IN: redis.assoc

TUPLE: redis-assoc host port encoding password ;

CONSTANT: default-redis-port 6379

: <redis-assoc> ( -- redis-assoc )
    redis-assoc new
        "127.0.0.1" >>host
        default-redis-port >>port
        latin1 >>encoding ;

INSTANCE: redis-assoc assoc

: with-redis-assoc ( redis-assoc quot -- )
    [
        [ host>> ] [ port>> ] [ encoding>> ] tri
        [ <inet> ] dip <client> drop
    ] dip with-stream ; inline

M: redis-assoc at* [ redis-get dup >boolean ] with-redis-assoc ;

M: redis-assoc assoc-size [ redis-dbsize ] with-redis-assoc ;

M: redis-assoc >alist
    [ "*" redis-keys dup redis-mget zip ] with-redis-assoc ;

M: redis-assoc set-at [ redis-set drop ] with-redis-assoc ;

M: redis-assoc delete-at [ redis-del drop ] with-redis-assoc ;

M: redis-assoc clear-assoc
    [ "*" redis-keys [ redis-del drop ] each ] with-redis-assoc ;

M: redis-assoc equal? assoc= ;

M: redis-assoc hashcode* assoc-hashcode ;
