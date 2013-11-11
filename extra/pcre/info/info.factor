USING:
    accessors
    alien alien.accessors alien.c-types alien.data alien.strings
    arrays
    io.encodings.utf8
    kernel
    math
    pcre.ffi pcre.utils
    sequences ;
IN: pcre.info

ERROR: bad-option what ;

! Mostly internal
: (fullinfo) ( pcre extra what -- ret obj )
    { int } [ pcre_fullinfo ] with-out-parameters ;

: fullinfo ( pcre extra what -- obj )
    [ (fullinfo) ] keep rot 0 = [ drop ] [ bad-option ] if ;

: name-count ( pcre extra -- n )
    PCRE_INFO_NAMECOUNT fullinfo ;

: name-table ( pcre extra -- addr )
    PCRE_INFO_NAMETABLE fullinfo ;

: name-entry-size ( pcre extra -- size )
    PCRE_INFO_NAMEENTRYSIZE fullinfo ;

: name-table-entry ( addr -- group-index group-name )
    [ <alien> 1 alien-unsigned-1 ] [ 2 + <alien> utf8 alien>string ] bi ;

: options ( pcre -- opts )
    f PCRE_INFO_OPTIONS fullinfo ;

! Exported
: name-table-entries ( pcre extra -- addrs )
    [ name-table ] [ name-entry-size ] [ name-count ] 2tri gen-array-addrs
    [ name-table-entry 2array ] map ;
