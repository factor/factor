USING: alien.c-types alien.syntax audio combinators
combinators.short-circuit io io.binary io.encodings.binary
io.files io.streams.byte-array kernel locals math
sequences alien alien.data classes.struct accessors ;
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

ERROR: invalid-wav-file ;

: ensured-read ( count -- output/f )
    [ read ] keep over length = [ drop f ] unless ;
: ensured-read* ( count -- output )
    ensured-read [ invalid-wav-file ] unless* ;

: read-chunk ( -- byte-array/f )
    4 ensured-read [ 4 ensured-read* dup le> ensured-read* 3append ] [ f ] if* ;
: read-riff-chunk ( -- byte-array/f )
    riff-chunk heap-size ensured-read* ;

: id= ( chunk id -- ? )
    [ 4 head ] dip sequence= ; inline

: check-chunk ( chunk id class -- ? )
    heap-size [ id= ] [ [ length ] dip >= ] bi-curry* bi and ;

:: read-wav-chunks ( -- fmt data )
    f :> fmt! f :> data!
    [ { [ fmt data and not ] [ read-chunk ] } 0&& dup ]
    [ {
        { [ dup FMT-MAGIC  wav-fmt-chunk  check-chunk ] [ wav-fmt-chunk  memory>struct fmt!  ] }
        { [ dup DATA-MAGIC wav-data-chunk check-chunk ] [ wav-data-chunk memory>struct data! ] }
    } cond ] while drop
    fmt data 2dup and [ invalid-wav-file ] unless ;

: verify-wav ( chunk -- )
    {
        [ RIFF-MAGIC id= ]
        [ riff-chunk memory>struct format>> 4 memory>byte-array WAVE-MAGIC id= ]
    } 1&&
    [ invalid-wav-file ] unless ;

: (read-wav) ( -- audio )
    read-wav-chunks
    [
        [ num-channels>>    2 memory>byte-array le> ]
        [ bits-per-sample>> 2 memory>byte-array le> ]
        [ sample-rate>>     4 memory>byte-array le> ] tri
    ] [
        [ header>> size>> 4 memory>byte-array le> dup ]
        [ body>> >c-ptr ] bi swap memory>byte-array
    ] bi* <audio> ;

: read-wav ( filename -- audio )
    binary [
        read-riff-chunk verify-wav (read-wav)
    ] with-file-reader ;
