! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data arrays checksums
checksums.md5 combinators command-line compression.zstd endian
io io.directories io.encodings.binary io.encodings.string
io.encodings.utf8 io.files io.files.info io.files.types
io.pathnames io.streams.byte-array kernel literals math
math.binpack math.statistics mime.types namespaces sequences
sequences.extras sets sorting splitting uuid zim ;

IN: zim.builder

: write-strings ( mime-types -- )
    [ utf8 encode write 0 write1 ] each 0 write1 ;

SYMBOLS: +zlib+ +bzip2+ +lzma+ +zstd+ ;

SYMBOL: zim-compression

: write-cluster-none ( blobs -- )
    1 write1 [
        dup length 1 + 4 * dup 4 >le write
        [ length + [ 4 >le write ] keep ] reduce drop
    ] [ [ write ] each ] bi ;

: write-cluster-zstd ( blobs -- )
    5 write1
    binary [ write-cluster-none ] with-byte-writer
    rest-slice zstd-compress write ;

: write-cluster ( blobs -- )
    zim-compression get {
        { f [ write-cluster-none ] }
        { +zstd+ [ write-cluster-zstd ] }
    } case ;

: cluster-bytes ( blobs -- byte-array )
    binary [ write-cluster ] with-byte-writer ;

: cluster-files ( paths -- byte-array )
    [ binary file-contents ] map cluster-bytes ;

:: new-zim ( zim-path -- )
    zim-header heap-size :> mime-list-ptr-pos
    mime-list-ptr-pos 1 + :> url-ptr-pos

    zim-path binary [
        zim-header new
            0x44D495A >>magic-number
            6 >>major-version
            1 >>minor-version
            uuid1 uuid-parse >>uuid
            0 >>entry-count
            0 >>cluster-count
            0xffffffff >>main-page
            0xffffffff >>layout-page
            mime-list-ptr-pos >>mime-list-ptr-pos
            url-ptr-pos >>url-ptr-pos
            url-ptr-pos >>title-ptr-pos
            url-ptr-pos >>cluster-ptr-pos
            url-ptr-pos >>checksum-pos
        write

        0 write1 ! mime-type-ptr-list
    ] with-file-writer

    zim-path md5 checksum-file
    zim-path binary [ write ] with-file-appender ;

: update-checksum ( zim-path -- )
    {
        [ binary [ 0 seek-end seek-input tell-input ] with-file-reader ]
        [ swap 16 - truncate-file ]
        [ md5 checksum-file ]
        [ binary [ write ] with-file-appender ]
    } cleave ;

CONSTANT: CLUSTER-SIZE $[ 2,048 1,024 * ]

:: binpack-clusters ( sizes -- bins blobs )
    sizes [ CLUSTER-SIZE > ] partition
    [ length ] [ sum CLUSTER-SIZE /mod zero? [ 1 + ] unless + ] bi* :> #clusters
    #clusters sizes length <= t assert=
    sizes length <iota> [ sizes nth ] #clusters map-binpack :> bins
    sizes length <iota> [| i |
        i bins [ index ] with find i swap index 2array
    ] map :> blobs bins blobs ;

:: build-zim ( zim-path -- )

    ! XXX: ZIM metadata?

    ! all files in the current directory
    "." recursive-directory-entries
    [ type>> +directory+ = ] reject
    [ name>> ] map sort :> paths

    ! entry metadata for each file
    paths [ mime-type ] map :> mime-types
    paths [ utf8 encode ] map :> urls
    paths [ file-info size>> ] map :> sizes

    ! unique mime-types list
    mime-types members sort :> mime-type-list
    mime-type-list length 0xffff < t assert=

    ! find the main page
    { "index.htm" "index.html" "main.htm" "main.html" }
    [ paths index ] map-find drop :> main-page

    ! calculate lengths and offsets
    zim-header heap-size :> header-len
    mime-type-list [ utf8 encode length 1 + ] map-sum 1 + :> mime-type-len
    paths length 8 * :> url-ptr-len
    paths length 4 * :> title-ptr-len

    ! make the entries
    urls [ length 18 + ] map :> entry-len
    entry-len cum-sum0 :> entry-ptrs
    entry-len sum :> entries-len

    ! make the clusters
    sizes binpack-clusters :> ( bins blobs )
    bins [ [ paths nth ] map cluster-files ] map :> clusters
    clusters length 8 * :> cluster-ptr-len
    clusters [ length ] map :> cluster-len
    cluster-len cum-sum0 :> cluster-ptrs
    cluster-len sum :> clusters-len

    ! compute the ptrs
    header-len dup        :> mime-list-ptr-pos
    mime-type-len + dup   :> url-ptr-pos
    url-ptr-len + dup     :> title-ptr-pos
    title-ptr-len + dup   :> cluster-ptr-pos
    cluster-ptr-len + dup :> entries-pos
    entries-len + dup     :> cluster-pos
    clusters-len +        :> checksum-pos

    ! write the zim file
    zim-path binary [

        zim-header new
            0x44D495A >>magic-number
            6 >>major-version
            1 >>minor-version
            uuid1 uuid-parse >>uuid
            paths length >>entry-count
            clusters length >>cluster-count
            main-page 0xffffffff or >>main-page
            0xffffffff >>layout-page
            mime-list-ptr-pos >>mime-list-ptr-pos
            url-ptr-pos >>url-ptr-pos
            title-ptr-pos >>title-ptr-pos
            cluster-ptr-pos >>cluster-ptr-pos
            checksum-pos >>checksum-pos
        write

        mime-type-list write-strings
        entry-ptrs [ entries-pos + 8 >le write ] each
        entry-ptrs [ drop 0xffffffff 4 >le write ] each
        cluster-ptrs [ cluster-pos + 8 >le write ] each

        mime-types urls [| mime-type url i |
            mime-type mime-type-list index 2 >le write
            0 write1            ! parameter-len
            CHAR: C write1      ! namespace
            0 4 >le write       ! revision
            i blobs nth first2  ! cluster-number
            [ 4 >le write ] bi@ ! blob-number
            url write 0 write1  ! url
            0 write1            ! title
        ] 2each-index

        clusters [ write ] each
    ] with-file-writer

    ! write the checksum
    zim-path md5 checksum-file
    zim-path binary [ write ] with-file-appender ;

ERROR: unknown-zim-option name ;

: zim-options ( command-line -- command-line' )
    [ "--" head? ] partition swap [
        "--" ?head drop {
            { "zstd" [ +zstd+ zim-compression namespaces:set ] }
            [ unknown-zim-option ]
        } case
    ] each ;

: build-zim-main ( -- )
    command-line get zim-options dup length 2 = [
        first2 [ absolute-path ] bi@ [ build-zim ] with-directory
    ] [
        drop "Usage: zim.builder [--zstd] output-path input-dir"
        print
    ] if ;

MAIN: build-zim-main
