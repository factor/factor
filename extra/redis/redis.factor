! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar io io.encodings.utf8 io.sockets
io.streams.duplex io.timeouts kernel redis.command-writer
redis.response-parser ;
QUALIFIED: namespaces
IN: redis

! Connection
: redis-quit ( -- ) quit flush ;
: redis-ping ( -- response ) ping flush read-response ;
: redis-auth ( password -- response ) auth flush read-response ;

! String values
: redis-set ( value key -- ) set flush check-response ;
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

! Key space
: redis-keys ( pattern -- response ) keys flush read-response ;
: redis-randomkey ( -- response ) randomkey flush read-response ;
: redis-rename ( newkey key -- response ) rename flush read-response ;
: redis-renamenx ( newkey key -- response ) renamenx flush read-response ;
: redis-dbsize ( -- response ) dbsize flush read-response ;
: redis-expire ( integer key -- response ) expire flush read-response ;

! Lists
: redis-rpush ( value key -- response ) rpush flush read-response ;
: redis-lpush ( value key -- response ) lpush flush read-response ;
: redis-llen ( key -- response ) llen flush read-response ;
: redis-lrange ( start end key -- response ) lrange flush read-response ;
: redis-ltrim ( start end key -- ) ltrim flush check-response ;
: redis-lindex ( integer key -- response ) lindex flush read-response ;
: redis-lset ( value index key -- ) lset flush check-response ;
: redis-lrem ( value amount key -- response ) lrem flush read-response ;
: redis-lpop ( key -- response ) lpop flush read-response ;
: redis-rpop ( key -- response ) rpop flush read-response ;

! Sets
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

! Hashes
: redis-hdel ( field key -- response ) hdel flush read-response ;
: redis-hexists ( field key -- response ) hexists flush read-response ;
: redis-hget ( field key -- response ) hget flush read-response ;
: redis-hgetall ( key -- response ) hgetall flush read-response ;
: redis-hincrby ( integer field key -- response ) hincrby flush read-response ;
: redis-hincrbyfloat ( float field key -- response ) hincrbyfloat flush read-response ;
: redis-hkeys ( key -- response ) hkeys flush read-response ;
: redis-hlen ( key -- response ) hlen flush read-response ;
: redis-hmget ( seq key  -- response ) hmget flush read-response ;
: redis-hmset ( assoc key -- ) hmset flush check-response ;
: redis-hset ( value field key -- response ) hset flush read-response ;
: redis-hsetnx ( value field key -- response ) hsetnx flush read-response ;
: redis-hvals ( key -- response ) hvals flush read-response ;

! Multiple db
: redis-select ( integer -- ) select flush check-response ;
: redis-move ( integer key -- response ) move flush read-response ;
: redis-flushdb ( -- ) flushdb flush check-response ;
: redis-flushall ( -- ) flushall flush check-response ;

! Sorting
! sort

! Persistence control
: redis-save ( -- ) save flush check-response ;
: redis-bgsave ( -- ) bgsave flush check-response ;
: redis-lastsave ( -- response ) lastsave flush read-response ;
: redis-shutdown ( -- ) shutdown flush check-response ;

! Remote server control
: redis-info ( -- response ) info flush read-response ;
: redis-monitor ( -- response ) monitor flush read-response ;

! Lua
: redis-script-load ( script -- script ) script-load flush read-response ;
: redis-script-exists ( sequence -- sequence ) script-exists flush read-response ;
: redis-script-flush ( -- ) script-flush flush check-response ;
: redis-script-kill ( -- ) script-kill flush check-response ;
: redis-script-eval ( script keys args -- result ) script-eval flush read-response ;
: redis-script-evalsha ( sha keys args -- result ) script-evalsha flush read-response ;

! Redis object
TUPLE: redis host port encoding password ;

SYMBOL: redis-host
"127.0.0.1" redis-host namespaces:set-global

SYMBOL: redis-port
6379 redis-port namespaces:set-global

: <redis> ( -- redis )
    redis new
        redis-host namespaces:get >>host
        redis-port namespaces:get >>port
        utf8 >>encoding ;

: redis-do-connect ( redis -- stream )
    [ host>> ] [ port>> ] [ encoding>> ] tri
    [ <inet> ] dip <client> drop
    1 minutes over set-timeout ;

: with-redis ( redis quot -- )
    [
        [ redis-do-connect ] [ password>> ] bi
        [ swap [ [ redis-auth drop ] with-stream* ] keep ] when*
    ] dip with-stream ; inline
