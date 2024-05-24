USING: accessors alien alien.c-types alien.data arrays bit-arrays
classes continuations destructors fry io io.streams.throwing kernel
locals math math.bitwise namespaces sequences words ;
IN: tools.image.analyzer.utils

: untag ( ptr -- ptr' )
    15 unmask ;

: class-heap-size ( instance -- n )
    class-of heap-size ;

: read-bytes>array ( nbytes type -- seq )
    [ read ] dip cast-array >array ;

: read-array ( count type -- seq )
    [ heap-size * ] keep read-bytes>array ;

: byte-array>bit-array ( byte-array -- bit-array )
    [ integer>bit-array 8 f pad-tail ] { } map-as concat ;

: word>byte-array ( word -- byte-array )
    word-code over - [ <alien> ] dip memory>byte-array ;

: until-eof-reader ( reader-quot -- reader-quot' )
    '[
        [ _ throw-on-eof ] [
            dup stream-exhausted? [ drop f ] [ throw ] if
        ] recover
    ] ; inline

: save-io-excursion ( quot -- )
    tell-input '[ _ seek-absolute seek-input ] finally ; inline

: consume-stream>sequence ( reader-quot: ( -- item )  -- seq )
    until-eof-reader '[ drop @ ] t swap follow rest ; inline

TUPLE: backwards-reader stream ;

M: backwards-reader dispose stream>> dispose ;

M: backwards-reader stream-element-type
    stream>> stream-element-type ;

M: backwards-reader stream-length
    stream>> stream-length ;

: backwards-seek ( ofs -- )
    dup 0 < [ seek-end ] [ seek-absolute ] if seek-input ;

M:: backwards-reader stream-read-unsafe ( n buf stream -- count )
    stream stream>> [
        tell-input n + :> pos-after
        pos-after neg backwards-seek
        n buf input-stream get stream-read-unsafe
        pos-after backwards-seek
    ] with-input-stream* ;

: <backwards-reader> ( stream -- stream' )
    backwards-reader boa ;
