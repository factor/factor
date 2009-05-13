! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel redis sequences ;
IN: redis.assoc

INSTANCE: redis assoc

M: redis at* [ redis-get dup >boolean ] with-redis ;

M: redis assoc-size [ redis-dbsize ] with-redis ;

M: redis >alist [ "*" redis-keys dup redis-mget zip ] with-redis ;

M: redis set-at [ redis-set drop ] with-redis ;

M: redis delete-at [ redis-del drop ] with-redis ;

M: redis clear-assoc [ redis-flushdb drop ] with-redis ;

M: redis equal? assoc= ;

M: redis hashcode* assoc-hashcode ;
