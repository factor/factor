USING:
    accessors
    alien.c-types alien.data
    arrays
    kernel
    pcre.ffi
    sequences ;
IN: pcre

ERROR: malformed-regexp expr error ;

TUPLE: compiled-pcre pcre extra ;

! Low-level

: exec ( pcre extra subject ofs -- count match-data )
    [ dup length ] dip 0 30 int <c-array> [ 30 pcre_exec ] keep ;

: (pcre) ( expr -- pcre err-message err-offset )
    0 { c-string int } [ f pcre_compile ] with-out-parameters ;

: <pcre> ( expr -- pcre )
    dup (pcre) 2array swap [ 2nip ] [ malformed-regexp ] if* ;

: <pcre-extra> ( pcre -- pcre-extra )
    0 { c-string } [ pcre_study ] with-out-parameters drop ;

! High-level

: <compiled-pcre> ( expr -- compiled-pcre )
    <pcre> dup <pcre-extra> compiled-pcre boa ;

: findall ( subject compiled-pcre -- matches )
    [ pcre>> ] [ extra>> ] bi rot 0 exec nip ;



: info ( pcre -- x x x )
    { int int } [ pcre_info ] with-out-parameters ;

: fullinfo ( pcre pcre-extra what -- num x )
    { int } [ pcre_fullinfo ] with-out-parameters ;

: substring ( subject match-data count n -- str )
    { c-string } [ pcre_get_substring drop ] with-out-parameters ;
