USING:
    accessors
    alien alien.accessors alien.c-types alien.data alien.strings
    arrays
    io.encodings.utf8
    kernel
    math math.bitwise
    pcre.ffi pcre.utils
    sequences ;
IN: pcre.info

! Mostly internal
: fullinfo ( pcre extra what -- obj )
    { int } [ pcre_fullinfo ] with-out-parameters nip ;

: name-count ( pcre extra -- n )
    PCRE_INFO_NAMECOUNT fullinfo ;

: name-table ( pcre extra -- addr )
    [ drop alien-address 32 on-bits unmask ]
    [ PCRE_INFO_NAMETABLE fullinfo ] 2bi + ;

: name-entry-size ( pcre extra -- size )
    PCRE_INFO_NAMEENTRYSIZE fullinfo ;

: name-table-entry ( addr -- group-index group-name )
    [ <alien> 1 alien-unsigned-1 ]
    [ 2 + <alien> utf8 alien>string ] bi ;

: options ( pcre -- opts )
    f PCRE_INFO_OPTIONS fullinfo ;

! Exported
: name-table-entries ( pcre extra -- addrs )
    [ name-table ] [ name-entry-size ] [ name-count ] 2tri
    gen-array-addrs [ name-table-entry 2array ] map ;
