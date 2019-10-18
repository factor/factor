! Copyright (C) 2007 Matthew Willis
! See http://factorcode.org/license.txt for BSD license.
USING: cryptlib cryptlib.libcl kernel alien sequences continuations
byte-arrays namespaces io.buffers math generic io strings
io.streams.lines io.streams.plain io.streams.duplex combinators
alien.c-types continuations ;

IN: cryptlib.streams

: set-attribute ( handle attribute value -- )
    cryptSetAttribute check-result ;

: set-attribute-string ( handle attribute value -- )
    dup length swap string>char-alien swap
    cryptSetAttributeString check-result ;

: default-buffer-size 64 1024 * ; inline

TUPLE: crypt-stream handle eof? ;

: init-crypt-stream ( handle -- )
    dup CRYPT_OPTION_NET_READTIMEOUT 1 set-attribute
    CRYPT_SESSINFO_ACTIVE 1 set-attribute ;

: <crypt-stream> ( handle -- stream )
    dup init-crypt-stream
    default-buffer-size <buffer>
    { set-crypt-stream-handle set-delegate }
    crypt-stream construct
    dup <line-reader> swap <plain-writer> <duplex-stream> ;

: check-read ( err -- eof? )
    {
        { [ dup CRYPT_ERROR_READ = ] [ drop t ] }
        { [ dup CRYPT_ERROR_COMPLETE = ] [ drop t ] }
        { [ dup CRYPT_ERROR_TIMEOUT = ] [ drop f ] }
        { [ t ] [ check-result f ] }
    } cond ;

: (refill) ( stream -- err )
    dup [ crypt-stream-handle ] keep [ buffer@ ] keep buffer-capacity
    "int" <c-object> dup >r cryptPopData r> *int rot n>buffer ;

: refill ( stream -- )
    dup (refill) check-read swap set-crypt-stream-eof? ;

: read-step ( n stream -- )
    dup refill tuck buffer-length 2dup <= 
    [ drop swap buffer> % ]
    [
        - swap dup buffer>> % dup crypt-stream-eof? 
        [ 2drop ] [ read-step ] if
    ] if ;

M: crypt-stream stream-read ( n stream -- str/f )
    tuck buffer-length 2dup <= [ drop swap buffer> ] [
        pick buffer>> [ % - swap read-step ] "" make f like
    ] if ;

M: crypt-stream stream-read1 ( stream -- ch/f )
    1 swap stream-read [ first ] [ f ] if* ;

: read-until-step ( seps stream -- sep/f )
    dup refill 2dup buffer-until [ swap % 2nip ]
    [ 
        % dup crypt-stream-eof? [ 2drop f ] [ read-until-step ] if
    ] if* ;

M: crypt-stream stream-read-until ( seps stream -- str/f sep/f )
    2dup buffer-until [ >r 2nip r> ] [
        [ % read-until-step ] "" make f like swap
    ] if* ;
 
M: crypt-stream stream-flush ( cl-stream -- )
    crypt-stream-handle cryptFlushData check-result ;

M: crypt-stream stream-write ( str stream -- )
    crypt-stream-handle over string>char-alien rot length
    "int" <c-object> cryptPushData check-result ;

M: crypt-stream stream-write1 ( ch stream -- )
    >r 1string r> stream-write ;

: check-close ( err -- )
    dup CRYPT_ERROR_PARAM1 = [ drop ] [ check-result ] if ;
    
M: crypt-stream dispose ( stream -- )
    crypt-stream-handle cryptDestroySession check-close ;

: create-session ( format -- session )
    "int" <c-object> tuck CRYPT_UNUSED rot
    cryptCreateSession check-result *int ;

: crypt-client ( server port -- handle )
    CRYPT_SESSION_SSL create-session
    [ CRYPT_SESSINFO_SERVER_PORT rot set-attribute ] keep
    [ CRYPT_SESSINFO_SERVER_NAME rot set-attribute-string ] keep ;

: crypt-server ( port -- handle )
    CRYPT_SESSION_SSL_SERVER create-session
    [ CRYPT_SESSINFO_SERVER_PORT rot set-attribute ] keep ;

: crypt-login ( handle user pass -- )
    swap pick CRYPT_SESSINFO_USERNAME rot set-attribute-string
    CRYPT_SESSINFO_PASSWORD swap set-attribute-string ;

: test-server ( -- stream )
    init
    8888 crypt-server
    dup "user" "pass" crypt-login
    <crypt-stream>
    
    "Welcome to cryptlib!" over stream-print 
    dup stream-flush
    
    dup stream-readln print
    
    dispose 
    end 
    ;
    
: test-client ( -- stream )
    init
    "localhost" 8888 crypt-client
    dup "user" "pass" crypt-login
    <crypt-stream>
    
    dup stream-readln print
    
    "Thanks!" over stream-print
    dup stream-flush
    
    dispose
    end 
    ;
    
: (rpl) ( stream -- stream )
    readln
    {
        { [ dup "." = ] 
            [ drop dup stream-readln "READ: " write print flush (rpl) ] }
        { [ dup "q" = ] [ drop ] }
        { [ t ] [ over stream-print dup stream-flush (rpl) ] }
    } cond ;

: test-rpl ( client? -- )
    ! a server where you type responses to the client manually
    init
    [ "localhost" 8888 crypt-client ] [ 8888 crypt-server ] if
    dup "user" "pass" crypt-login
    <crypt-stream>
    
    (rpl)
    
    dispose 
    end 
    ;
