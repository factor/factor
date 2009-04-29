USING: alien.c-types alien.syntax audio combinators
combinators.short-circuit io io.binary io.encodings.binary
io.files io.streams.memory kernel locals sequences ;
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
    { "uchar[0]" "body" }
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

: read-chunk ( -- byte-array/f )
    4 read [ 4 read le> [ <uint> ] [ read ] bi 3append ] [ f ] if* ;

: id= ( chunk id -- ? )
    [ 4 memory>byte-array ] dip sequence= ;

:: read-wav-chunks ( -- fmt data )
    f :> fmt! f :> data!
    [ { [ fmt data and not ] [ read-chunk ] } 0&& dup ]
    [ {
        { [ dup FMT-MAGIC  id= ] [ fmt!  ] }
        { [ dup DATA-MAGIC id= ] [ data! ] }
    } cond ] while drop
    fmt data ;

ERROR: invalid-wav-file ;

: verify-wav ( chunk -- )
    { [ RIFF-MAGIC id= ] [ riff-chunk-format WAVE-MAGIC id= ] } 1&&
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
        read-chunk
        [ verify-wav ]
        [ riff-chunk-body <memory-stream> [ (read-wav) ] with-input-stream* ] bi
    ] with-file-reader ;
