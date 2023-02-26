! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs formatting kernel math math.parser
sequences strings make ;
IN: redis.command-writer

<PRIVATE

GENERIC: write-resp ( value -- )

M: string write-resp ( string -- )
    [ length ] keep "$%s\r\n%s\r\n" printf ;

M: integer write-resp ( integer -- )
    ":%s\r\n" printf ;

M: sequence write-resp ( sequence -- )
    [ length "*%s\r\n" printf ] keep
    [ write-resp ] each ;

: write-command ( sequence command -- )
    suffix reverse
    [ dup number? [ number>string ] when ] map
    write-resp ;

: write-command-multi ( sequence command -- )
    prepend
    [ dup number? [ number>string ] when ] map
    write-resp ;

:: (script-eval) ( script keys args command -- )
    [ script , keys length , keys % args % ] { } make
    { command }
    write-command-multi ;

PRIVATE>

! Connection
: quit ( -- ) { "QUIT" } write-resp ;
: ping ( -- ) { "PING" } write-resp ;
: auth ( password -- ) 1array "AUTH" write-command ;

! String values
: set ( value key -- ) 2array "SET" write-command ;
: get ( key -- ) 1array "GET" write-command ;
: getset ( value key -- ) 2array "GETSET" write-command ;
: mget ( keys -- ) reverse "MGET" write-command ;
: setnx ( value key -- ) 2array "SETNX" write-command ;
: incr ( key -- ) 1array "INCR" write-command ;
: incrby ( integer key -- ) 2array "INCRBY" write-command ;
: decr ( key -- ) 1array "DECR" write-command ;
: decrby ( integer key -- ) 2array "DECRBY" write-command ;
: exists ( key -- ) 1array "EXISTS" write-command ;
: del ( key -- ) 1array "DEL" write-command ;
: type ( key -- ) 1array "TYPE" write-command ;

! Key space
: keys ( pattern -- ) 1array "KEYS" write-command ;
: randomkey ( -- ) { "RANDOMKEY" } write-resp ;
: rename ( newkey key -- ) 2array "RENAME" write-command ;
: renamenx ( newkey key -- ) 2array "RENAMENX" write-command ;
: dbsize ( -- ) { "DBSIZE" } write-resp ;
: expire ( integer key -- ) 2array "EXPIRE" write-command ;

! Lists
: rpush ( value key -- ) 2array "RPUSH" write-command ;
: lpush ( value key -- ) 2array "LPUSH" write-command ;
: llen ( key -- ) 1array "LLEN" write-command ;
: lrange ( start end key -- )
    swapd 3array "LRANGE" write-command ;
: ltrim ( start end key -- )
    swapd 3array "LTRIM" write-command ;
: lindex ( integer key -- ) 2array "LINDEX" write-command ;
: lset ( value index key -- ) 3array "LSET" write-command ;
: lrem ( value amount key -- ) 3array "LREM" write-command ;
: lpop ( key -- ) 1array "LPOP" write-command ;
: rpop ( key -- ) 1array "RPOP" write-command ;

! Sets
: sadd ( member key -- ) 2array "SADD" write-command ;
: srem  ( member key -- ) 2array "SREM" write-command ;
: smove ( member newkey key -- )
    3array "SMOVE" write-command ;
: scard ( key -- ) 1array "SCARD" write-command ;
: sismember ( member key -- )
    2array "SISMEMBER" write-command ;
: sinter ( keys -- ) reverse "SINTER" write-command ;
: sinterstore ( keys destkey -- )
    [ reverse ] dip suffix "SINTERSTORE" write-command ;
: sunion ( keys -- ) reverse "SUNION" write-command ;
: sunionstore ( keys destkey -- )
    [ reverse ] dip suffix "SUNIONSTORE" write-command ;
: smembers ( key -- ) 1array "SMEMBERS" write-command ;

! Hashes
: hdel ( field key -- ) 2array "HDEL" write-command ;
: hexists ( field key -- ) 2array "HEXISTS" write-command ;
: hget ( field key -- ) 2array "HGET" write-command ;
: hgetall ( key -- ) 1array "HGETALL" write-command ;
: hincrby ( integer field key -- )
    3array "HINCRBY" write-command ;
: hincrbyfloat ( float field key -- )
    3array "HINCRBYFLOAT" write-command ;
: hkeys ( key -- ) 1array "HKEYS" write-command ;
: hlen ( key -- ) 1array "HLEN" write-command ;
: hmget ( seq key -- ) prefix reverse "HMGET" write-command ;
: hmset ( assoc key -- )
    [
        >alist concat reverse
    ] dip suffix "HMSET" write-command ;
: hset ( value field key -- ) 3array "HSET" write-command ;
: hsetnx ( value field key -- )
    3array "HSETNX" write-command ;
: hvals ( key -- ) 1array "HVALS" write-command ;

! Multiple db
: select ( integer -- ) 1array "SELECT" write-command ;
: move ( integer key -- ) 2array "MOVE" write-command ;
: swapdb ( old new -- ) 2array "SWAPDB" write-command ;
: flushdb ( -- ) { "FLUSHDB" } write-resp ;
: flushall ( -- ) { "FLUSHALL" } write-resp ;

! Sorting
! sort

! Persistence control
: save ( -- ) { "SAVE" } write-resp ;
: bgsave ( -- ) { "BGSAVE" } write-resp ;
: lastsave ( -- ) { "LASTSAVE" } write-resp ;
: shutdown ( -- ) { "SHUTDOWN" } write-resp ;

! Remote server control
: info ( -- ) { "INFO" } write-resp ;
: monitor ( -- ) { "MONITOR" } write-resp ;

! Lua
: script-load ( script -- ) 1array { "SCRIPT" "LOAD" } write-command-multi ;
: script-exists ( scripts -- ) { "SCRIPT" "EXISTS" } write-command-multi ;
: script-flush ( -- ) { } { "SCRIPT" "FLUSH" } write-command-multi ;
: script-kill ( -- ) { } { "SCRIPT" "KILL" } write-command-multi ;
! YES | SYNC | NO
: script-debug ( debug -- ) 1array { "SCRIPT" "DEBUG" } write-command-multi ;
: script-evalsha ( sha keys args -- ) "EVALSHA" (script-eval) ;
: script-eval ( script keys args -- ) "EVAL" (script-eval) ;
