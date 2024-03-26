! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar checksums combinators.short-circuit
http.client io io.directories io.encodings.binary io.files
io.files.info io.files.unique io.pathnames kernel math
math.order math.parser present sequences shuffle splitting ;

IN: http.download

: file-too-old-or-not-exists? ( path duration -- ? )
    [ ?file-info [ created>> ] ?call ]
    [ ago ] bi*
    over [ before? ] [ 2drop t ] if ;

: delete-when-old ( path duration -- deleted? )
    dupd file-too-old-or-not-exists? [ ?delete-file t ] [ drop f ] if ;

: file-matches-checksum? ( path checksum-type bytes -- ? )
    [ checksum-file ] dip = ;

: delete-when-checksum-mismatches ( path checksum-type bytes -- deleted? )
    dupdd file-matches-checksum? [ drop f ] [ ?delete-file t ] if ;

: file-size= ( path n -- ? ) [ ?file-info [ size>> ] ?call ] dip = ;

: file-zero-size? ( path -- ? ) 0 file-size= ;

: delete-when-zero-size ( path -- deleted-or-not-exists? )
    dup file-exists? [
        dup file-zero-size? [ ?delete-file t ] [ drop f ] if
    ] [
        drop t
    ] if ;

: delete-when-file-size-mismatches? ( path size -- deleted? )
    dupd file-size= [ drop f ] [ ?delete-file t ] if ;

: download-name ( url -- name )
    present file-name "?" split1 drop "/" ?tail drop ;

<PRIVATE

: increment-file-extension ( path -- path' )
    dup file-extension
    [ ?tail drop ]
    [
        [ string>number ]
        [ 1 + number>string append ]
        [ ".1" 3append ] ?if
    ] bi ;

: ?parenthesis-number ( str -- n/f )
    [
        {
            [ "(" head? ]
            [ ")" tail? ]
            [ rest but-last string>number ]
        } 1&&
    ] [ drop f ] ?unless ;

: increment-file-name ( path -- path' )
    [
        file-stem " " split1-last
        [ ?parenthesis-number ]
        [ 1 + number>string "(" ")" surround " " glue ]
        [ "(1)" append " " glue ] ?if
    ] [
        file-extension
    ] bi "." glue ;

: find-next-incremented-name ( path -- path' )
    dup file-exists? [
        increment-file-name find-next-incremented-name
    ] when ;

: next-download-name ( url -- name )
    download-name find-next-incremented-name ;

: http-write-request ( url -- )
    <get-request> [ write ] with-http-request drop ;

: download-temporary-name ( url -- prefix suffix )
    [ "temp." ".temp" ] dip download-name prepend ;

PRIVATE>

: download-to ( url path -- path )
    [
        [ download-temporary-name binary ] keep
        '[ _ http-write-request ] with-unique-file-writer
    ] dip [ move-file ] keep ;

: download-once-to ( url path -- path )
    dup file-exists? [ nip ] [ download-to ] if ;

: download-once ( url -- path )
    dup download-name download-once-to ;

: download-outdated-to ( url path duration -- path )
    2dup delete-when-old [ drop download-to ] [ drop nip ] if ;

: download ( url -- path )
    dup download-name download-to ;
