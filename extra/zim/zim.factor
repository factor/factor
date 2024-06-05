! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data arrays assocs
binary-search classes.struct combinators
combinators.short-circuit compression.zstd destructors endian io
io.encodings.binary io.encodings.string io.encodings.utf8
io.files kernel lru-cache math math.bitwise math.order sequences
sequences.private splitting ;

IN: zim

! https://openzim.org/wiki/ZIM_file_format

! XXX: make sure this is always little-endian

PACKED-STRUCT: zim-header
    { magic-number uint32_t }
    { major-version uint16_t }
    { minor-version uint16_t }
    { uuid uint8_t[16] }
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
    2 read le> ;

: read-uint32 ( -- n )
    4 read le> ;

: read-uint64 ( -- n )
    8 read le> ;

: read-string ( -- str )
    { 0 } read-until 0 assert= utf8 decode ;

: read-mime-types ( -- seq )
    [ read-string dup empty? not ] [ ] produce nip ;

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
    read-uint32 dup 4 /i f <array> [ set-first ] keep
    dup rest-slice [ drop read-uint32 ] map! drop
    dup [ last ] [ first ] bi - read ;

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

TUPLE: zim < disposable path stream header mime-types urls titles
    entries clusters cluster-cache ;

M: zim dispose* [ dispose f ] change-stream drop ;

: read-zim ( path -- zim )
    [ zim new-disposable ] dip [ >>path ] keep
    binary <file-reader> [ >>stream ] keep [
        zim-header read-struct [ >>header ] keep {
            [ magic-number>> 0x44D495A assert= ]
            [
                mime-list-ptr-pos>> seek-absolute seek-input
                read-mime-types >>mime-types
            ] [
                dup url-ptr-pos>> seek-absolute seek-input
                entry-count>> [ read-uint64 ] replicate
                >>urls
            ] [
                dup title-ptr-pos>> seek-absolute seek-input
                entry-count>> [ read-uint32 ] replicate
                >>titles
            ] [
                entry-count>> f <array>
                >>entries
            ] [
                dup cluster-ptr-pos>> seek-absolute seek-input
                cluster-count>> [ read-uint64 ] replicate
                >>clusters
            ]
        } cleave 32 <lru-hash> >>cluster-cache
    ] with-input-stream* ;

: with-zim ( zim quot -- )
    [ dup stream>> ] [ with-input-stream* ] bi* ; inline

: (read-entry-index) ( n zim -- entry/f )
    urls>> nth dup 0xffffffff = [ drop f ] [
        seek-absolute seek-input read-entry
    ] if ;

:: read-entry-index ( n zim -- entry/f )
    n 0xffffffff = [ f ] [
        zim entries>> :> entries
        n entries nth [
            n zim (read-entry-index) dup n entries set-nth
        ] unless*
    ] if ;

: read-blob-index ( blob-number cluster-number zim -- blob )
    [ cluster-cache>> ] keep '[
        _ clusters>> nth seek-absolute seek-input
        read-cluster zim-cluster boa
    ] cache nth ;

GENERIC#: read-entry-content 1 ( entry zim -- blob mime-type )

M:: content-entry read-entry-content ( entry zim -- blob mime-type )
    entry blob-number>>
    entry cluster-number>>
    zim read-blob-index
    entry mime-type>>
    zim mime-types>> nth ;

M: redirect-entry read-entry-content
    [ redirect-index>> ] [ read-entry-content ] bi* ;

M: integer read-entry-content
    [ read-entry-index ] keep '[ _ read-entry-content ] [ f f ] if* ;

: read-main-page ( zim -- blob/f mime-type/f )
    [ header>> main-page>> ] [ read-entry-content ] bi ;

:: (find-entry-url) ( url zim -- entry/f )
    zim header>> entry-count>> <iota> [
        zim read-entry-index url over url>> = and*
    ] map-find drop ;

:: (find-entry-url-full) ( namespace url zim -- entry/f )
    f zim header>> entry-count>> <iota> [
        nip zim read-entry-index
        namespace over namespace>> <=>
        dup +eq+ = [ drop url over url>> <=> ] when
    ] search 2drop dup {
        [ ] [ namespace>> namespace = ] [ url>> url = ]
    } 1&& and* ;

: find-entry-url ( namespace/f url zim -- entry/f )
    pick [ (find-entry-url-full) ] [ (find-entry-url) nip ] if ;

: read-entry-url ( namespace/f url zim -- blob/f mime-type/f )
    [ find-entry-url ] keep '[ _ read-entry-content ] [ f f ] if* ;

M: zim length header>> entry-count>> ;

M: zim nth-unsafe
    [
        ! read-entry-index
        [ read-entry-index dup ]
        [ read-entry-content drop ] bi 2array
    ] with-zim ;

INSTANCE: zim sequence

M: zim assoc-size header>> entry-count>> ;

M: zim at*
    [
        [
            "/" split
            dup { [ length 1 > ] [ first length 1 = ] } 1&&
            [ unclip-slice first ] [ f ] if swap "/" join
        ] [ read-entry-url 2array t ] bi*
    ] with-zim ;

INSTANCE: zim assoc
