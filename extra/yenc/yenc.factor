! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs checksums checksums.crc32 combinators
endian formatting io.encodings.binary io.files io.files.info
kernel locals make math math.functions math.order math.parser
namespaces sequences splitting strings ;

IN: yenc

ERROR: invalid-yenc reason ;

SYMBOL: yenc-line-length
yenc-line-length [ 128 ] initialize

<PRIVATE

: yenc-line% ( -- )
    building get length yenc-line-length get
    [ 2 + ] bi@ divisor? [ "\r\n" % ] when ;

: yenc% ( bytes -- )
    [
        42 + 256 mod
        dup "\0\r\n=" member? [ CHAR: = , 64 + 256 mod ] when ,
        yenc-line%
    ] each ;

PRIVATE>

: yenc ( bytes -- yenc )
    [ yenc% ] B{ } make ;

<PRIVATE

: ybegin% ( path -- )
    [ file-info size>> yenc-line-length get ] keep
    "=ybegin size=%d line=%d name=%s\n" sprintf % ;

: yend% ( path -- )
    [ file-info size>> ] [ crc32 checksum-file be> ] bi
    "\n=yend size=%d crc32=%08X" sprintf % ;

PRIVATE>

: yenc-file ( path -- yenc )
    [
        [ ybegin% ]
        [ binary file-contents yenc% ]
        [ yend% ] tri
    ] B{ } make ;

<PRIVATE

: ydec, ( encode? ch -- encode?' )
    dup "\r\n" member? [ drop ] [
        2dup [ not ] [ CHAR: = = ] bi* and [ 2drop t ] [
            over [ 64 - [ drop f ] dip ] when
            dup 0 41 between? [ 214 + ] [ 42 - ] if ,
        ] if
    ] if ;

PRIVATE>

: ydec ( yenc -- bytes )
    [ f swap [ ydec, ] each drop ] B{ } make ;

<PRIVATE

! The name is the final field and may itself contain spaces and equals signs.
: parse-fields ( line -- metadata )
    " " split harvest [ "=" split1 ] H{ } map>assoc ;

: parse-metadata ( line -- metadata )
    >string "\r" ?tail drop " name=" split1
    [ parse-fields ] dip [ "name" pick set-at ] when* ;

:: find-metadata ( lines type -- metadata i )
    lines [ type head? ] find :> ( i line )
    i [ line type length tail parse-metadata i ]
    [ "Missing envelope marker" invalid-yenc ] if ;

:: metadata-number ( metadata key -- n )
    key metadata at dup [ string>number ] when
    dup integer? [ "Invalid numeric metadata" invalid-yenc ] unless ;

:: check-size ( expected actual -- )
    expected actual = [ "Size mismatch" invalid-yenc ] unless ;

:: check-crc ( bytes metadata key -- )
    key metadata at [
        dup length 8 = over [ "0123456789abcdefABCDEF" member? ] all? and
        [ hex> ] [ "Invalid CRC32" invalid-yenc ] if
        bytes crc32 checksum-bytes be> =
        [ "CRC32 mismatch" invalid-yenc ] unless
    ] when* ;

:: check-part ( header trailer part bytes -- )
    header "part" metadata-number :> number
    number 0 > [ "Invalid part number" invalid-yenc ] unless
    number trailer "part" metadata-number check-size
    "total" header at [
        drop header "total" metadata-number :> total
        number total <= [ "Invalid part count" invalid-yenc ] unless
        "total" trailer key? [
            total trailer "total" metadata-number check-size
        ] when
    ] when*
    part "begin" metadata-number :> first
    part "end" metadata-number :> last
    header "size" metadata-number :> size
    first 1 >= last first >= and last size <= and
    [ "Invalid part range" invalid-yenc ] unless
    last first - 1 + bytes length check-size
    "pcrc32" trailer key? [ "Missing part CRC32" invalid-yenc ] unless
    bytes trailer "pcrc32" check-crc
    ! A whole-file CRC can only be verified when this part spans the file.
    first 1 = last size = and [ bytes trailer "crc32" check-crc ] when ;

PRIVATE>

:: ydec-file ( yenc -- ybegin yend bytes )
    yenc "\n" split :> lines
    lines "=ybegin " find-metadata :> ( header start )
    lines start 1 + tail :> remaining
    remaining "=yend " find-metadata :> ( trailer end )
    remaining end head :> body
    "part" header key? [
        body empty? [ "Missing part header" invalid-yenc ] when
        body first >string "=ypart " ?head
        [ parse-metadata ] [ "Missing part header" invalid-yenc ] if :> part
        body rest B{ } join ydec :> bytes
        header trailer part bytes check-part
        part header assoc-union trailer bytes
    ] [
        body B{ } join ydec :> bytes
        header "size" metadata-number bytes length check-size
        bytes trailer "crc32" check-crc
        header trailer bytes
    ] if
    dup length trailer "size" metadata-number check-size ;
