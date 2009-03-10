! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors constructors images io io.binary io.encodings.ascii
io.encodings.binary io.encodings.string io.files io.files.info kernel
sequences io.streams.limited ;
IN: images.png

TUPLE: png-image < image chunks ;

CONSTRUCTOR: png-image ( -- image )
V{ } clone >>chunks ;

TUPLE: png-chunk length type data crc ;

CONSTRUCTOR: png-chunk ( -- png-chunk ) ;

CONSTANT: png-header B{ HEX: 89 HEX: 50 HEX: 4e HEX: 47 HEX: 0d HEX: 0a HEX: 1a HEX: 0a }

ERROR: bad-png-header header ;

: read-png-header ( -- )
    8 read dup png-header sequence= [
        bad-png-header
    ] unless drop ;

: read-png-chunks ( image -- image )
    <png-chunk>
    4 read be> >>length
    4 read ascii decode >>type
    dup length>> read >>data
    4 read >>crc
    [ over chunks>> push ] 
    [ type>> ] bi "IEND" =
    [ read-png-chunks ] unless ;

: load-png ( path -- image )
    [ binary <file-reader> ] [ file-info size>> ] bi stream-throws <limited-stream> [
        <png-image>
        read-png-header
        read-png-chunks
    ] with-input-stream ;
