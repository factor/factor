! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data audio
audio.chunked-file audio.loader classes.struct combinators
combinators.short-circuit endian io.encodings.binary io.files
kernel ;
IN: audio.wav

CONSTANT: RIFF-MAGIC "RIFF"
CONSTANT: WAVE-MAGIC "WAVE"
CONSTANT: FMT-MAGIC  "fmt "
CONSTANT: DATA-MAGIC "data"

STRUCT: riff-chunk-header
    { id char[4] }
    { size char[4] } ;

STRUCT: riff-chunk
    { header riff-chunk-header }
    { format char[4] } ;

STRUCT: wav-fmt-chunk
    { header riff-chunk-header }
    { audio-format uchar[2] }
    { num-channels uchar[2] }
    { sample-rate uchar[4] }
    { byte-rate uchar[4] }
    { block-align uchar[2] }
    { bits-per-sample uchar[2] } ;

STRUCT: wav-data-chunk
    { header riff-chunk-header }
    { body uchar[0] } ;

: read-riff-chunk ( -- byte-array/f )
    riff-chunk heap-size ensured-read* ;

:: read-wav-chunks ( -- fmt data )
    f :> fmt! f :> data!
    [ { [ fmt data and not ] [ read-chunk ] } 0&& ]
    [ {
        { [ dup FMT-MAGIC  wav-fmt-chunk  check-chunk ] [ wav-fmt-chunk  memory>struct fmt!  ] }
        { [ dup DATA-MAGIC wav-data-chunk check-chunk ] [ wav-data-chunk memory>struct data! ] }
        [ drop ]
    } cond ] while*
    fmt data 2dup and [ invalid-audio-file ] unless ;

: verify-wav ( chunk -- )
    {
        [ RIFF-MAGIC id= ]
        [ riff-chunk memory>struct format>> 4 memory>byte-array WAVE-MAGIC id= ]
    } 1&&
    [ invalid-audio-file ] unless ;

: (read-wav) ( -- audio )
    read-wav-chunks
    [
        [ num-channels>>    2 memory>byte-array le> ]
        [ bits-per-sample>> 2 memory>byte-array le> ]
        [ sample-rate>>     4 memory>byte-array le> ] tri
    ] [
        [ header>> size>> 4 memory>byte-array le> dup ]
        [ body>> >c-ptr ] bi swap memory>byte-array
    ] bi*
    <audio> convert-data-endian ;

: read-wav ( filename -- audio )
    little-endian [
        binary [
            read-riff-chunk verify-wav (read-wav)
        ] with-file-reader
    ] with-endianness ;

"wav" [ read-wav ] register-audio-extension
