USING: alien.c-types alien.syntax audio combinators
combinators.short-circuit io io.binary io.encodings.binary
io.files io.streams.byte-array kernel locals math
sequences ;
IN: audio.wav

CONSTANT: RIFF-MAGIC "RIFF"
CONSTANT: WAVE-MAGIC "WAVE"
CONSTANT: FMT-MAGIC  "fmt "
CONSTANT: DATA-MAGIC "data"

C-STRUCT: riff-chunk-header
    { "char[4]" "id" }
    { "uchar[4]" "size" }
    ;

C-STRUCT: riff-chunk
    { "riff-chunk-header" "header" }
    { "char[4]" "format" }
    ;

C-STRUCT: wav-fmt-chunk
    { "riff-chunk-header" "header" }
    { "uchar[2]" "audio-format" }
    { "uchar[2]" "num-channels" }
    { "uchar[4]" "sample-rate" }
    { "uchar[4]" "byte-rate" }
    { "uchar[2]" "block-align" }
    { "uchar[2]" "bits-per-sample" }
    ;

C-STRUCT: wav-data-chunk
    { "riff-chunk-header" "header" }
    { "uchar[0]" "body" }
    ;

ERROR: invalid-wav-file ;

: ensured-read ( count -- output/f )
    [ read ] keep over length = [ drop f ] unless ;
: ensured-read* ( count -- output )
    ensured-read [ invalid-wav-file ] unless* ;

: read-chunk ( -- byte-array/f )
    4 ensured-read [ 4 ensured-read* dup le> ensured-read* 3append ] [ f ] if* ;
: read-riff-chunk ( -- byte-array/f )
    "riff-chunk" heap-size ensured-read* ;

: id= ( chunk id -- ? )
    [ 4 head ] dip sequence= ;

: check-chunk ( chunk id min-size -- ? )
    [ id= ] [ [ length ] dip >= ] bi-curry* bi and ;

:: read-wav-chunks ( -- fmt data )
    f :> fmt! f :> data!
    [ { [ fmt data and not ] [ read-chunk ] } 0&& dup ]
    [ {
        { [ dup FMT-MAGIC  "wav-fmt-chunk"  heap-size check-chunk ] [ fmt!  ] }
        { [ dup DATA-MAGIC "wav-data-chunk" heap-size check-chunk ] [ data! ] }
    } cond ] while drop
    fmt data 2dup and [ invalid-wav-file ] unless ;

: verify-wav ( chunk -- )
    {
        [ RIFF-MAGIC id= ]
        [ riff-chunk-format 4 memory>byte-array WAVE-MAGIC id= ]
    } 1&&
    [ invalid-wav-file ] unless ;

: (read-wav) ( -- audio )
    read-wav-chunks
    [
        [ wav-fmt-chunk-num-channels    2 memory>byte-array le> ]
        [ wav-fmt-chunk-bits-per-sample 2 memory>byte-array le> ]
        [ wav-fmt-chunk-sample-rate     4 memory>byte-array le> ] tri
    ] [
        [ riff-chunk-header-size 4 memory>byte-array le> dup ]
        [ wav-data-chunk-body ] bi swap memory>byte-array
    ] bi* <audio> ;

: read-wav ( filename -- audio )
    binary [
        read-riff-chunk verify-wav (read-wav)
    ] with-file-reader ;
