USING:
    accessors
    alien.c-types alien.data alien.strings
    arrays
    assocs
    grouping
    io.encodings.utf8 io.encodings.string
    kernel
    locals
    math
    pcre.ffi pcre.info
    sequences
    strings ;
IN: pcre

ERROR: malformed-regexp expr error ;
ERROR: pcre-error value ;

TUPLE: compiled-pcre pcre extra nametable ;
TUPLE: matcher subject compiled-pcre ofs match ;

: default-opts ( -- opts )
    PCRE_UTF8 PCRE_UCP bitor ;

: (pcre) ( expr -- pcre err-message err-offset )
    default-opts { c-string int } [ f pcre_compile ] with-out-parameters ;

: <pcre> ( expr -- pcre )
    dup (pcre) 2array swap [ 2nip ] [ malformed-regexp ] if* ;

:: exec ( subject ofs pcre extra -- count match-data )
    pcre extra subject dup length ofs 0 30 int <c-array>
    [ 30 pcre_exec ] keep ;

: <pcre-extra> ( pcre -- pcre-extra )
    0 { c-string } [ pcre_study ] with-out-parameters drop ;

: config ( what -- alien )
    { int } [ pcre_config ] with-out-parameters ;

! Finding stuff
: (findnext) ( subject ofs compiled-pcre -- match/f )
    [ pcre>> ] [ extra>> ] bi exec over
    dup -1 < [ pcre-error ] [ dup -1 = [ 3drop f ] [ drop 2array ] if ] if ;

: findnext ( matcher -- matcher'/f )
    clone dup [ subject>> ] [ ofs>> ] [ compiled-pcre>> ] tri (findnext)
    [ [ >>match ] [ second second >>ofs ] bi ] [ drop f ] if* ;

! Result parsing
: substring-list ( subject match-data count -- alien )
    { void* } [ pcre_get_substring_list drop ] with-out-parameters ;

: parse-groups ( ngroups seq -- match )
    swap 2 * head 2 <groups> [ >array ] map ;

: parse-match ( subject compiled-pcre match-data -- match )
    swapd first2 swap [ substring-list ] keep void* <c-direct-array>
    [ alien>native-string ] { } map-as [ nametable>> ] dip
    [ of swap 2array ] with map-index ;

! High-level
: <compiled-pcre> ( expr -- compiled-pcre )
    <pcre> dup <pcre-extra> 2dup name-table-entries compiled-pcre boa ;

GENERIC: findall ( subject obj -- matches )

M: compiled-pcre findall
    [ utf8 encode ] dip 2dup 0 f matcher boa [ findnext ] follow
    [ match>> ] map harvest [ parse-match ] 2with map ;

M: string findall
    <compiled-pcre> findall ;

GENERIC: matches? ( subject obj -- ? )

M: compiled-pcre matches?
    dupd findall [ nip length 1 = ] [ ?first ?first ?last = ] 2bi and ;

M: string matches?
    <compiled-pcre> matches? ;
