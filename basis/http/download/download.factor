! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar checksums combinators.short-circuit
http http.client io io.directories io.encodings.binary io.files
io.files.info io.files.unique io.pathnames kernel math
math.order math.parser mime.types namespaces present sequences
shuffle splitting strings urls ;
IN: http.download

: file-too-old-or-not-exists? ( path duration -- ? )
    [ ?file-info [ created>> ] ?call ]
    [ ago ] bi*
    over [ before? ] [ 2drop t ] if ;

: delete-when-old ( path duration -- deleted/missing? )
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

: http-write-request ( url -- headers )
    <get-request> [ write ] with-http-request ;

: download-temporary-name ( url -- prefix suffix )
    [ "temp." ".temp" ] dip download-name prepend ;

PRIVATE>

GENERIC: download-to-temporary-file ( obj -- path )

M: string download-to-temporary-file
    >url download-to-temporary-file ;

M: request download-to-temporary-file
    url>> download-to-temporary-file ;

M: url download-to-temporary-file
    [ download-temporary-name binary ] keep
    '[ _ http-write-request ] with-unique-file-writer
    swap [ dup ".temp" ?tail drop ]
    [
        content-type>> mime-type>extension "temp" or "." glue
        find-next-incremented-name
    ] bi* [ move-file ] keep ;

: download-as ( url path -- path )
    [ download-to-temporary-file ] dip [ ?move-file ] keep ;

: download-into ( url directory -- path )
    [ [ download-to-temporary-file ] keep ] dip
    dup make-directories to-directory nip
    [ move-file ] keep ;

: download ( url -- path )
    dup download-name download-as ;

: download-once-as ( url path -- path )
    dup file-exists? [ nip ] [ download-as ] if ;

: download-once-into ( url directory -- path ) to-directory download-once-as ;

: download-once ( url -- path ) current-directory get download-once-into ;

: download-outdated-as ( url path duration -- path' )
    2dup delete-when-old [ drop download-as ] [ drop nip ] if ;

: download-outdated-into ( url directory duration -- path )
    [ to-directory ] dip download-outdated-as ;

: download-outdated ( url duration -- path )
    [ dup download-name current-directory get to-directory nip ] dip download-outdated-as ;
