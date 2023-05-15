! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data arrays assocs
binary-search classes.struct combinators
combinators.short-circuit compression.zstd http.server
http.server.responses io io.encodings.binary io.encodings.string
io.encodings.utf8 io.files kernel lru-cache math math.bitwise
math.order namespaces prettyprint sequences sequences.private
strings ;

IN: zim

! https://openzim.org/wiki/ZIM_file_format

PACKED-STRUCT: zim-header
    { magic-number uint32_t }
    { major-version uint16_t }
    { minor-version uint16_t }
    { uuid uint64_t[2] }
    { entry-count uint32_t }
    { cluster-count uint32_t }
    { url-ptr-pos uint64_t }
    { title-ptr-pos uint64_t }
    { cluster-ptr-pos uint64_t }
    { mime-list-ptr-pos uint64_t }
    { main-page uint32_t }
    { layout-page uint32_t }
    { checksum-pos uint64_t } ;

: read-uint16 ( -- n )
    2 read uint16_t deref ;

: read-uint32 ( -- n )
    4 read uint32_t deref ;

: read-uint64 ( -- n )
    8 read uint64_t deref ;

: read-string ( -- str )
    { 0 } read-until 0 assert= utf8 decode ;

: read-mime-types ( -- seq )
    [ read-string dup empty? not ] [ utf8 decode ] produce nip ;

TUPLE: content-entry mime-type parameter-len namespace
    revision cluster-number blob-number url title parameter ;

: read-content-entry ( mime-type -- content-entry )
    read1
    read1
    read-uint32
    read-uint32
    read-uint32
    read-string
    read-string
    f
    content-entry boa
    dup parameter-len>> read >>parameter ;

TUPLE: redirect-entry mime-type parameter-len namespace revision
    redirect-index url title parameter ;

: read-redirect-entry ( mime-type -- redirect-entry )
    read1
    read1
    read-uint32
    read-uint32
    read-string
    read-string
    f
    redirect-entry boa
    dup parameter-len>> read >>parameter ;

: read-entry ( -- entry )
    read-uint16 dup 0xffff =
    [ read-redirect-entry ] [ read-content-entry ] if ;

: read-cluster-none ( -- offsets blobs )
    read-uint32 [ 1 - [ read-uint32 ] replicate ] [ prefix ] bi
    dup last read ;

: read-cluster-zstd ( -- offsets blobs )
    zstd-uncompress-stream-frame dup uint32_t deref
    [ 4 /i uint32_t <c-direct-array> ] [ tail-slice ] 2bi
    2dup [ [ last ] [ first ] bi - ] [ length assert= ] bi* ;

: read-cluster ( -- offsets blobs )
    read1 [ 5 bit? f assert= ] [ 4 bits ] bi {
        { 1 [ read-cluster-none ] }
        { 2 [ "zlib not supported" throw ] }
        { 3 [ "bzip2 not supported" throw ] }
        { 4 [ "lzma not supported" throw ] }
        { 5 [ read-cluster-zstd ] }
    } case ;

:: read-cluster-blob ( n -- blob )
    read-cluster :> ( offsets blobs )
    0 offsets nth :> zero
    n offsets nth :> from
    n 1 + offsets nth :> to
    from to [ zero - ] bi@ blobs subseq ;

TUPLE: zim-cluster offsets blobs ;

M: zim-cluster length offsets>> length 1 - ;

M:: zim-cluster nth-unsafe ( n cluster -- blob )
    cluster offsets>> :> offsets
    cluster blobs>> :> blobs
    0 offsets nth :> zero
    n offsets nth :> from
    n 1 + offsets nth :> to
    from to [ zero - ] bi@ blobs subseq ;

INSTANCE: zim-cluster sequence

TUPLE: zim path header mime-types urls titles clusters cluster-cache ;

: read-zim ( path -- zim )
    dup binary [
        zim-header read-struct dup {
            [
                mime-list-ptr-pos>> seek-absolute seek-input
                read-mime-types
            ] [
                dup url-ptr-pos>> seek-absolute seek-input
                entry-count>> [ read-uint64 ] replicate
                ! [ seek-absolute seek-input read-entry ] map
            ] [
                dup title-ptr-pos>> seek-absolute seek-input
                entry-count>> [ read-uint32 ] replicate
            ] [
                dup cluster-ptr-pos>> seek-absolute seek-input
                cluster-count>> [ read-uint64 ] replicate
            ]
        } cleave 32 <lru-hash> zim boa
    ] with-file-reader ;

: read-uint32-offset ( n ptr-pos -- offset/f )
    over 0xffffffff = [ 2drop f ] [
        [ 4 * ] [ + ] bi* seek-absolute seek-input read-uint32
    ] if ;

: read-uint64-offset ( n ptr-pos -- offset/f )
    over 0xffffffff = [ 2drop f ] [
        [ 8 * ] [ + ] bi* seek-absolute seek-input read-uint64
    ] if ;

: read-url-offset ( n zim -- offset/f )
    header>> url-ptr-pos>> read-uint64-offset ;

: read-title-offset ( n zim -- offset/f )
    header>> title-ptr-pos>> read-uint32-offset ;

: read-cluster-offset ( n zim -- offset/f )
    header>> cluster-ptr-pos>> read-uint64-offset ;

: with-zim-reader ( zim quot -- )
    [ path>> binary ] [ with-file-reader ] bi* ; inline

: read-entry-index ( n zim -- entry/f )
    urls>> nth seek-absolute seek-input read-entry ;

: read-cluster-index ( blob-number cluster-number zim -- blob )
    [ cluster-cache>> ] [ clusters>> ] bi '[
        _ nth seek-absolute seek-input
        read-cluster zim-cluster boa
    ] cache nth ;

DEFER: read-content-index

GENERIC#: read-entry-cluster 1 ( entry zim -- blob mime-type )

M:: content-entry read-entry-cluster ( entry zim -- blob mime-type )
    entry blob-number>>
    entry cluster-number>>
    zim read-cluster-index
    entry mime-type>>
    zim mime-types>> nth ;

M: redirect-entry read-entry-cluster
    [ redirect-index>> ] [ read-content-index ] bi* ;

: read-content-index ( n zim -- blob/f mime-type/f )
    [ read-entry-index ] keep '[ _ read-entry-cluster ] [ f f ] if* ;

: read-main-page ( zim -- blob/f mime-type/f )
    [ header>> main-page>> ] [ read-content-index ] bi ;

:: read-entry-url ( namespace url zim -- blob mime-type )
    ! XXX: fix double read-entry-index on success
    zim header>> entry-count>> <iota> [
        zim read-entry-index
        dup namespace>> namespace >=< dup +eq+ =
        [ drop url>> url >=< ] [ nip ] if
    ] search nip zim read-entry-index :> entry
    entry zim read-entry-cluster ;

M: zim length header>> entry-count>> ;

M: zim nth-unsafe
    dup [
        [ read-entry-index ]
        [ read-content-index drop ] 2bi 2array
    ] with-zim-reader ;

INSTANCE: zim sequence

CONSTANT: USER-CONTENT CHAR: C
CONSTANT: ZIM-METADATA CHAR: M
CONSTANT: WELL-KNOWN CHAR: W
CONSTANT: SEARCH-INDEX CHAR: X

CONSTANT: iso639 H{
    { "ara" "ar" }
    { "dan" "da" }
    { "nld" "nl" }
    { "eng" "en" }
    { "fin" "fi" }
    { "fra" "fr" }
    { "deu" "de" }
    { "hun" "hu" }
    { "ita" "it" }
    { "nor" "no" }
    { "por" "pt" }
    { "ron" "ro" }
    { "rus" "ru" }
    { "spa" "es" }
    { "swe" "sv" }
    { "tur" "tr" }
}

TUPLE: zim-responder zim ;

: <zim-responder> ( path -- zim-responder )
    read-zim zim-responder boa ;

M: zim-responder call-responder*
    [
        dup { [ length 1 > ] [ first length 1 = ] } 1&&
        [ unclip-slice first ] [ CHAR: A ] if swap "/" join
        dup { "" "index.htm" "index.html" "main.htm" "main.html" }
        member? [ drop f ] when
    ] [
        zim>> dup [
            over [ read-entry-url ] [ 2nip read-main-page ] if
        ] with-zim-reader
    ] bi* <content> binary >>content-encoding ;

: zim-main ( -- )
    command-line get [
        "Usage: zim path" print
    ] [
        first <zim-responder> main-responder set-global
        8080 httpd wait-for-server
    ] if-empty ;

MAIN: zim-main
