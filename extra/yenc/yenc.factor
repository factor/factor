! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs checksums checksums.crc32 combinators
endian formatting io.encodings.binary io.files io.files.info
kernel make math math.functions math.order namespaces sequences
splitting strings ;

IN: yenc

! TODO: Support yparts

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
    [ file-info size>> ] [ crc32 checksum-bytes be> ] bi
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

: parse-metadata ( line -- metadata )
    >string " " split [ "=" split1 ] H{ } map>assoc ;

: find-metadata ( lines type -- metadata i )
    [ '[ _ head? ] find ] keep ?head drop parse-metadata swap ;

PRIVATE>

: ydec-file ( yenc -- ybegin yend bytes )
    "\n" split {
        [ "=ybegin " find-metadata 1 + ]
        [ "=yend " find-metadata swapd ]
        [ <slice> ]
    } cleave [
        f swap [ [ ydec, ] each ] each drop
    ] B{ } make ;
