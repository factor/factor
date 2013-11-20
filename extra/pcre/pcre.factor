USING: accessors alien alien.accessors alien.c-types alien.data
alien.enums alien.strings arrays assocs fry io.encodings.string
io.encodings.utf8 kernel math math.bitwise mirrors pcre.ffi
sequences sequences.generalizations splitting strings ;
QUALIFIED: regexp
IN: pcre

<PRIVATE

: 2with ( param1 param2 obj quot -- obj curry )
    [ -rot ] dip [ [ rot ] dip call ] 3curry ; inline

: gen-array-addrs ( base size n -- addrs )
    iota [ * + ] 2with map ;

: utf8-start-byte? ( byte -- ? )
    0xc0 bitand 0x80 = not ;

: next-utf8-char ( byte-array pos -- pos' )
    1 + 2dup swap ?nth
    [ utf8-start-byte? [ nip ] [ next-utf8-char ] if ] [ 2drop f ] if* ;

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

: name-table-entries ( pcre extra -- addrs )
    [ name-table ] [ name-entry-size ] [ name-count ] 2tri
    gen-array-addrs [ name-table-entry 2array ] map ;

PRIVATE>

ERROR: malformed-regexp expr error ;
ERROR: pcre-error value ;

TUPLE: compiled-pcre pcre extra nametable ;

: default-opts ( -- opts )
    PCRE_UTF8 PCRE_UCP bitor ;

: (pcre) ( expr -- pcre err-message err-offset )
    default-opts { c-string int } [ f pcre_compile ] with-out-parameters ;

: <pcre> ( expr -- pcre )
    dup (pcre) 2array swap [ 2nip ] [ malformed-regexp ] if* ;

: exec ( pcre extra subject ofs opts -- count match-data )
    [ dup length ] 2dip 30 int <c-array> 30 [ pcre_exec ] 2keep drop ;

: <pcre-extra> ( pcre -- pcre-extra )
    0 { c-string } [ pcre_study ] with-out-parameters drop ;

: config ( what -- alien )
    { int } [ pcre_config ] with-out-parameters ;

! Finding stuff
TUPLE: matcher pcre extra subject ofs exec-opts match ;

: <matcher> ( subject compiled-pcre -- matcher )
    [ utf8 encode ] dip [ pcre>> ] [ extra>> ] bi rot 0 0 f matcher boa ;

! This handling of zero-length matches is taken from pcredemo.c
: empty-match-opts ( -- opts )
    PCRE_NOTEMPTY_ATSTART PCRE_ANCHORED bitor ;

: findnext ( matcher -- matcher'/f )
    clone dup <mirror> values 6 firstn drop exec
    over dup -1 < [ PCRE_ERRORS number>enum pcre-error ] when
    -1 =
    [
        2drop dup exec-opts>> 0 =
        [ drop f ]
        [
            dup [ subject>> ] [ ofs>> ] bi next-utf8-char
            [ >>ofs 0 >>exec-opts findnext ] [ drop f ] if*
        ] if
    ]
    [
        [ 2array >>match ]
        [
            nip
            [ first2 = [ empty-match-opts ] [ 0 ] if >>exec-opts ]
            [ second >>ofs ] bi
        ] 2bi
    ] if ;

! Result parsing
: substring-list ( subject match-array count -- alien )
    { void* } [ pcre_get_substring_list drop ] with-out-parameters ;

: parse-match ( subject nametable match-data -- match )
    swapd first2 swap [ substring-list ] keep void* <c-direct-array>
    [ utf8 alien>string ] { } map-as [ of swap 2array ] with map-index ;

! High-level
: <compiled-pcre> ( expr -- compiled-pcre )
    <pcre> dup <pcre-extra> 2dup name-table-entries compiled-pcre boa ;

: has-option? ( compiled-pcre option -- ? )
    [ pcre>> options ] dip bitand 0 > ;

GENERIC: findall ( subject obj -- matches )

M: compiled-pcre findall
    [ <matcher> [ findnext ] follow [ match>> ] map harvest ]
    [ nametable>> rot [ parse-match ] 2with { } map-as ] 2bi ;

M: string findall
    <compiled-pcre> findall ;

M: regexp:regexp findall
    raw>> findall ;

: matches? ( subject obj -- ? )
    dupd findall [ nip length 1 = ] [ ?first ?first ?last = ] 2bi and ;

<PRIVATE

: replace-all ( seq subseqs new -- seq )
    swapd '[ _ replace ] reduce ;

: split-subseqs ( seq subseqs -- seqs )
    dup first [ replace-all ] keep split-subseq [ >string ] map harvest ;

PRIVATE>

: split ( subject obj -- strings )
    dupd findall [ first second ] map split-subseqs ;
