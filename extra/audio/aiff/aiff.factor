! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data audio
audio.chunked-file audio.loader classes.struct combinators
combinators.short-circuit endian io.encodings.binary io.files
kernel math sequences ;
IN: audio.aiff

CONSTANT: FORM-MAGIC "FORM"
CONSTANT: AIFF-MAGIC "AIFF"
CONSTANT: COMM-MAGIC "COMM"
CONSTANT: SSND-MAGIC "SSND"

STRUCT: aiff-chunk-header
    { id char[4] }
    { size char[4] } ;

STRUCT: form-chunk
    { header aiff-chunk-header }
    { form-type char[4] } ;

STRUCT: common-chunk
    { header aiff-chunk-header }
    { num-channels uchar[2] }
    { num-sample-frames uchar[4] }
    { sample-size uchar[2] }
    { sample-rate uchar[10] } ;

STRUCT: sound-data-chunk
    { header aiff-chunk-header }
    { offset uchar[4] }
    { block-size uchar[4] }
    { waveform-data uchar[0] } ;

! cheesy long-double>integer converter that assumes the long double is a positive integer
: sample-rate>integer ( byte[10] -- sample-rate )
    2 cut-slice [ be> ] bi@ swap 16383 - 63 - shift ;

: read-form-chunk ( -- byte-array/f )
    form-chunk heap-size ensured-read* ;

: verify-aiff ( chunk -- )
    {
        [ FORM-MAGIC id= ]
        [ form-chunk memory>struct form-type>> 4 memory>byte-array AIFF-MAGIC id= ]
    } 1&&
    [ invalid-audio-file ] unless ;

:: read-aiff-chunks ( -- comm ssnd )
    f :> comm! f :> ssnd!
    [ { [ comm ssnd and not ] [ read-chunk ] } 0&& dup ]
    [ {
        {
            [ dup COMM-MAGIC common-chunk check-chunk ]
            [ common-chunk memory>struct comm! ]
        }
        {
            [ dup SSND-MAGIC sound-data-chunk check-chunk ]
            [ sound-data-chunk memory>struct ssnd! ]
        }
        [ drop ]
    } cond ] while drop
    comm ssnd 2dup and [ invalid-audio-file ] unless ;

: (read-aiff) ( -- audio )
    read-aiff-chunks
    [
        [ num-channels>>    2 memory>byte-array be> ]
        [ sample-size>>     2 memory>byte-array be> ]
        [ sample-rate>>     sample-rate>integer ] tri
    ] [
        [ header>> size>> 4 memory>byte-array be> 8 - dup ]
        [ waveform-data>> >c-ptr ] bi swap memory>byte-array
    ] bi*
    <audio> convert-data-endian ;

: read-aiff ( filename -- audio )
    big-endian [
        binary [
            read-form-chunk verify-aiff (read-aiff)
        ] with-file-reader
    ] with-endianness ;

"aif"  [ read-aiff ] register-audio-extension
"aiff" [ read-aiff ] register-audio-extension
