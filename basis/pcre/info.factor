USING:
    accessors
    alien alien.accessors alien.c-types alien.data alien.strings
    arrays
    kernel
    math
    pcre.ffi
    sequences ;
IN: pcre.info

! Gen. utility
: 2with ( param1 param2 obj quot -- obj curry )
    [ -rot ] dip [ [ rot ] dip call ] 3curry ; inline

: gen-array-addrs ( base size n -- addrs )
    iota [ * + ] 2with map ;

! Mostly internal
: fullinfo ( pcre extra what -- obj )
    { int } [ pcre_fullinfo ] with-out-parameters nip ;

: name-count ( pcre extra -- n )
    PCRE_INFO_NAMECOUNT fullinfo ;

: name-table ( pcre extra -- addr )
    PCRE_INFO_NAMETABLE fullinfo ;

: name-entry-size ( pcre extra -- size )
    PCRE_INFO_NAMEENTRYSIZE fullinfo ;

: name-table-entry ( addr -- group-index group-name )
    [ <alien> 1 alien-unsigned-1 ] [ 2 + <alien> alien>native-string ] bi ;

: options ( pcre -- opts )
    f PCRE_INFO_OPTIONS fullinfo ;

! Exported
: name-table-entries ( pcre extra -- addrs )
    [ name-table ] [ name-entry-size ] [ name-count ] 2tri gen-array-addrs
    [ name-table-entry 2array ] map ;
