! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: io io.crlf kernel math.parser sequences strings interpolate locals ;
IN: redis.command-writer

<PRIVATE

GENERIC: write-value-with-length ( value -- )

M: string write-value-with-length
    [ length number>string write crlf ]
    [ write ] bi ;

: space ( -- ) CHAR: space write1 ;

: write-key/value ( value key -- )
    write space
    write-value-with-length ;

: write-key/integer ( integer key -- )
    write space
    number>string write ;

PRIVATE>

#! Connection
: quit ( -- ) "QUIT" write crlf ;
: ping ( -- ) "PING" write crlf ;
: auth ( password -- ) "AUTH " write write crlf ;

#! String values
: set ( value key -- ) "SET " write write-key/value crlf ;
: get ( key -- ) "GET " write write crlf ;
: getset ( value key -- ) "GETSET " write write-key/value crlf ;
: mget ( keys -- ) "MGET " write " " join write crlf ;
: setnx ( value key -- ) "SETNX " write write-key/value crlf ;
: incr ( key -- ) "INCR " write write crlf ;
: incrby ( integer key -- ) "INCRBY " write write-key/integer crlf ;
: decr ( key -- ) "DECR " write write crlf ;
: decrby ( integer key -- ) "DECRBY " write write-key/integer crlf ;
: exists ( key -- ) "EXISTS " write write crlf ;
: del ( key -- ) "DEL " write write crlf ;
: type ( key -- ) "TYPE " write write crlf ;

#! Key space
: keys ( pattern -- ) "KEYS " write write crlf ;
: randomkey ( -- ) "RANDOMKEY" write crlf ;
: rename ( newkey key -- ) "RENAME " write write space write crlf ;
: renamenx ( newkey key -- ) "RENAMENX " write write space write crlf ;
: dbsize ( -- ) "DBSIZE" write crlf ;
: expire ( integer key -- ) "EXPIRE " write write-key/integer crlf ;

#! Lists
: rpush ( value key -- ) "RPUSH " write write-key/value crlf ;
: lpush ( value key -- ) "LPUSH " write write-key/value crlf ;
: llen ( key -- ) "LLEN " write write crlf ;
: lrange ( start end key -- )
    "LRANGE " write write [ space number>string write ] bi@ crlf ;
: ltrim ( start end key -- )
    "LTRIM " write write [ space number>string write ] bi@ crlf ;
: lindex ( integer key -- ) "LINDEX " write write-key/integer crlf ;
: lset ( value index key -- )
    "LSET " write write-key/integer space write-value-with-length crlf ;
: lrem ( value amount key -- )
    "LREM " write write-key/integer space write-value-with-length crlf ;
: lpop ( key -- ) "LPOP " write write crlf ;
: rpop ( key -- ) "RPOP " write write crlf ;

#! Sets
: sadd ( member key -- )
    "SADD " write write space write-value-with-length crlf ;
: srem  ( member key -- )
    "SREM " write write space write-value-with-length crlf ;
: smove ( member newkey key -- )
    "SMOVE " write write space write space write-value-with-length crlf ;
: scard ( key -- ) "SCARD " write write crlf ;
: sismember ( member key -- )
    "SISMEMBER " write write space write-value-with-length crlf ;
: sinter ( keys -- ) "SINTER " write " " join write crlf ;
: sinterstore ( keys destkey -- )
    "SINTERSTORE " write write space " " join write crlf ;
: sunion ( keys -- ) "SUNION " write " " join write crlf ;
: sunionstore ( keys destkey -- )
    "SUNIONSTORE " write write " " join space write crlf ;
: smembers ( key -- ) "SMEMBERS " write write crlf ;

#! Multiple db
: select ( integer -- ) "SELECT " write number>string write crlf ;
: move ( integer key -- ) "MOVE " write write-key/integer crlf ;
: flushdb ( -- ) "FLUSHDB" write crlf ;
: flushall ( -- ) "FLUSHALL" write crlf ;

#! Sorting
! sort

#! Persistence control
: save ( -- ) "SAVE" write crlf ;
: bgsave ( -- ) "BGSAVE" write crlf ;
: lastsave ( -- ) "LASTSAVE" write crlf ;
: shutdown ( -- ) "SHUTDOWN" write crlf ;

#! Remote server control
: info ( -- ) "INFO" write crlf ;
: monitor ( -- ) "MONITOR" write crlf ;
