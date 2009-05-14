! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io io.encodings.8-bit io.sockets
io.streams.duplex kernel redis.command-writer
redis.response-parser splitting ;
IN: redis

#! Connection
: redis-quit ( -- ) quit flush ;
: redis-ping ( -- response ) ping flush read-response ;
: redis-auth ( password -- response ) auth flush read-response ;

#! String values
: redis-set ( value key -- response ) set flush read-response ;
: redis-get ( key -- response ) get flush read-response ;
: redis-getset ( value key -- response ) getset flush read-response ;
: redis-mget ( keys -- response ) mget flush read-response ;
: redis-setnx ( value key -- response ) setnx flush read-response ;
: redis-incr ( key -- response ) incr flush read-response ;
: redis-incrby ( integer key -- response ) incrby flush read-response ;
: redis-decr ( key -- response ) decr flush read-response ;
: redis-decrby ( integer key -- response ) decrby flush read-response ;
: redis-exists ( key -- response ) exists flush read-response ;
: redis-del ( key -- response ) del flush read-response ;
: redis-type ( key -- response ) type flush read-response ;

#! Key space
: redis-keys ( pattern -- response ) keys flush read-response " " split ;
: redis-randomkey ( -- response ) randomkey flush read-response ;
: redis-rename ( newkey key -- response ) rename flush read-response ;
: redis-renamenx ( newkey key -- response ) renamenx flush read-response ;
: redis-dbsize ( -- response ) dbsize flush read-response ;
: redis-expire ( integer key -- response ) expire flush read-response ;

#! Lists
: redis-rpush ( value key -- response ) rpush flush read-response ;
: redis-lpush ( value key -- response ) lpush flush read-response ;
: redis-llen ( key -- response ) llen flush read-response ;
: redis-lrange ( start end key -- response ) lrange flush read-response ;
: redis-ltrim ( start end key -- response ) ltrim flush read-response ;
: redis-lindex ( integer key -- response ) lindex flush read-response ;
: redis-lset ( value index key -- response ) lset flush read-response ;
: redis-lrem ( value amount key -- response ) lrem flush read-response ;
: redis-lpop ( key -- response ) lpop flush read-response ;
: redis-rpop ( key -- response ) rpop flush read-response ;

#! Sets
: redis-sadd ( member key -- response ) sadd flush read-response ;
: redis-srem  ( member key -- response ) srem flush read-response ;
: redis-smove ( member newkey key -- response ) smove flush read-response ;
: redis-scard ( key -- response ) scard flush read-response ;
: redis-sismember ( member key -- response ) sismember flush read-response ;
: redis-sinter ( keys -- response ) sinter flush read-response ;
: redis-sinterstore ( keys destkey -- response ) sinterstore flush read-response ;
: redis-sunion ( keys -- response ) sunion flush read-response ;
: redis-sunionstore ( keys destkey -- response ) sunionstore flush read-response ;
: redis-smembers ( key -- response ) smembers flush read-response ;

#! Multiple db
: redis-select ( integer -- response ) select flush read-response ;
: redis-move ( integer key -- response ) move flush read-response ;
: redis-flushdb ( -- response ) flushdb flush read-response ;
: redis-flushall ( -- response ) flushall flush read-response ;

#! Sorting
! sort

#! Persistence control
: redis-save ( -- response ) save flush read-response ;
: redis-bgsave ( -- response ) bgsave flush read-response ;
: redis-lastsave ( -- response ) lastsave flush read-response ;
: redis-shutdown ( -- response ) shutdown flush read-response ;

#! Remote server control
: redis-info ( -- response ) info flush read-response ;
: redis-monitor ( -- response ) monitor flush read-response ;

#! Redis object
TUPLE: redis host port encoding password ;

CONSTANT: default-redis-port 6379

: <redis> ( -- redis )
    redis new
        "127.0.0.1" >>host
        default-redis-port >>port
        latin1 >>encoding ;

: redis-do-connect ( redis -- stream )
    [ host>> ] [ port>> ] [ encoding>> ] tri
    [ <inet> ] dip <client> drop ;

: with-redis ( redis quot -- )
    [
        [ redis-do-connect ] [ password>> ] bi
        [ swap [ [ redis-auth drop ] with-stream* ] keep ] when*
    ] dip with-stream ; inline
