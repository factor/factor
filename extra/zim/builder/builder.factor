! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data arrays checksums
checksums.md5 endian io io.directories io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.files.info
io.files.types kernel math math.statistics mime.types sequences
sequences.extras sets sorting uuid zim ;

IN: zim.builder

: write-strings ( mime-types -- )
    [ utf8 encode write 0 write1 ] each 0 write1 ;

CONSTANT: COMPRESS_NONE 1
CONSTANT: COMPRESS_ZLIB 2
CONSTANT: COMPRESS_BZIP2 3
CONSTANT: COMPRESS_LZMA 4
CONSTANT: COMPRESS_ZSTD 5

: write-cluster ( blobs -- )
    COMPRESS_NONE write1 [
        dup length 1 + 4 * dup 4 >le write
        [ length + [ 4 >le write ] keep ] reduce drop
    ] [ [ write ] each ] bi ;

:: build-zim ( zim-path -- )

    ! XXX: ZIM metadata?
    ! XXX: assumes one blob per cluster

    ! get all files and metadata
    "." recursive-directory-entries
    [ type>> +directory+ = ] reject
    [ name>> ] map sort :> paths

    paths [ mime-type ] map :> mime-types
    paths [ utf8 encode ] map :> urls
    paths [ file-info size>> ] map :> sizes

    ! calculate unique mime-types
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
    paths length 8 * :> cluster-ptr-len

    urls [ length 18 + ] map :> entry-len
    entry-len cum-sum0 :> entry-ptrs
    entry-len sum :> entries-len

    sizes [ 9 + ] map :> cluster-len
    cluster-len cum-sum0 :> cluster-ptrs
    cluster-len sum :> clusters-len

    ! the layout will be
    ! 1) zim header
    ! 2) mime-types
    ! 3) url-ptrs
    ! 4) title-ptrs
    ! 5) cluster-ptrs
    ! 6) entries
    ! 7) clusters
    header-len dup        :> mime-list-ptr-pos
    mime-type-len + dup   :> url-ptr-pos
    url-ptr-len + dup     :> title-ptr-pos
    title-ptr-len + dup   :> cluster-ptr-pos
    cluster-ptr-len + dup :> entries-pos
    entries-len + dup     :> cluster-pos
    clusters-len +        :> checksum-pos

    zim-path binary [

        zim-header new
            0x44D495A >>magic-number
            6 >>major-version
            1 >>minor-version
            uuid1 uuid-parse uint64_t cast-array >>uuid
            paths length >>entry-count
            paths length >>cluster-count
            main-page 0xffffffff or >>main-page
            0xffffffff >>layout-page
            mime-list-ptr-pos >>mime-list-ptr-pos
            url-ptr-pos >>url-ptr-pos
            title-ptr-pos >>title-ptr-pos
            cluster-ptr-pos >>cluster-ptr-pos
            checksum-pos >>checksum-pos
        write

        mime-type-list write-strings

        ! write-url-ptrs
        entry-ptrs [ entries-pos + 8 >le write ] each

        ! write-title-ptrs
        paths length [ 0xffffffff 4 >le write ] times

        ! write-cluster-ptrs
        cluster-ptrs [ cluster-pos + 8 >le write ] each

        ! write-entries
        mime-types urls [| mime-type url i |
            mime-type mime-type-list index 2 >le write
            0 write1           ! parameter-len
            CHAR: C write1     ! namespace
            0 4 >le write      ! revision
            i 4 >le write      ! cluster-number
            0 4 >le write      ! blob-number
            url write 0 write1 ! url
            0 write1           ! title
        ] 2each-index

        ! write-clusters
        paths [| path |
            path binary file-contents 1array write-cluster
        ] each

    ] with-file-writer

    ! calculate md5 checksum
    zim-path md5 checksum-file :> checksum

    ! write-checksum
    zim-path binary [ checksum write ] with-file-appender

    ;
