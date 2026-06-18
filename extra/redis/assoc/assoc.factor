! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel redis sequences ;
IN: redis.assoc

INSTANCE: redis assoc

M: redis at* [ 1array redis-get dup >boolean ] with-redis ;

M: redis assoc-size [ { } redis-dbsize ] with-redis ;

M: redis >alist
    [ { "*" } redis-keys [ { } ] [ dup redis-mget zip ] if-empty ] with-redis ;

M: redis set-at [ swap 2array redis-set drop ] with-redis ;

M: redis delete-at [ 1array redis-del drop ] with-redis ;

M: redis clear-assoc [ { } redis-flushdb drop ] with-redis ;

M: redis equal? assoc= ;

M: redis hashcode* assoc-hashcode ;
