! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs endian io io.directories
io.encodings.binary io.files kernel math sequences serialize ;

IN: bitcask

<PRIVATE

: write-entry-bytes ( key value/f -- )
    [ dup length 4 >be write ] bi@ [ write ] bi@ ;

: write-entry ( key value -- )
    [ object>bytes ] bi@ write-entry-bytes ;

: write-tombstone ( key -- )
    object>bytes f write-entry-bytes ;

: read-entry ( -- value/f ? )
    4 read be> 4 read be> [
        drop f f
    ] [
        [ seek-relative seek-input ]
        [ read bytes>object t ] bi*
    ] if-zero ;

: read-index ( -- index )
    H{ } clone [
        4 read [
            be> read bytes>object 4 read be>
            swap pick set-at t
        ] [ f ] if*
    ] loop ;

: write-index ( index -- )
    [
        [ object>bytes dup length 4 >be write write ]
        [ 4 >be write ] bi*
    ] assoc-each ;

: recover-index ( index -- index' )
    dup values [ maximum seek-absolute seek-input ] unless-empty
    [
        tell-input 4 read [
            be> 4 read be> [ read bytes>object ] dip
            [ pick delete-at drop ] [
                [ pick set-at ]
                [ seek-relative seek-input ] bi*
            ] if-zero t
        ] [ drop f ] if*
    ] loop ;

PRIVATE>

TUPLE: bitcask path index ;

:: <bitcask> ( path -- bitcask )
    path dup touch-file
    path ".idx" append dup touch-file
    binary [ read-index ] with-file-reader
    path binary [ recover-index ] with-file-reader
    bitcask boa ;

: save-index ( bitcask -- )
    dup path>> ".idx" append binary
    [ index>> write-index ] with-file-writer ;

M:: bitcask delete-at ( key bitcask -- )
    key bitcask index>> key? [
        bitcask path>> binary [
            key write-tombstone
            key bitcask index>> delete-at
        ] with-file-appender
    ] when ;

M:: bitcask at* ( key bitcask -- value/f ? )
    key bitcask index>> at* [
        bitcask path>> binary [
            seek-absolute seek-input read-entry
        ] with-file-reader
    ] [ drop f f ] if ;

M:: bitcask set-at ( value key bitcask -- )
    bitcask path>> binary [
        tell-output
        key value write-entry
        key bitcask index>> set-at
    ] with-file-appender ;

M: bitcask assoc-size index>> assoc-size ;

M: bitcask >alist
    dup path>> binary [
        index>> [
            seek-absolute seek-input read-entry t assert=
        ] { } assoc-map-as
    ] with-file-reader ;

M: bitcask keys index>> keys ;

M: bitcask values
    dup path>> binary [
        index>> values [
            seek-absolute seek-input read-entry t assert=
        ] map
    ] with-file-reader ;

M: bitcask clear-assoc
    dup path>> binary [
        index>> dup keys [ write-tombstone ] each clear-assoc
    ] with-file-appender ;

INSTANCE: bitcask assoc
