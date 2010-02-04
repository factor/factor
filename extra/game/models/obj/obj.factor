! Copyright (C) 2010 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings.ascii math.parser sequences splitting kernel
assocs io.files combinators math.order math namespaces
arrays sequences.deep accessors
specialized-arrays.instances.alien.c-types.float
specialized-arrays.instances.alien.c-types.uint
game.models.util gpu.shaders images game.models.loader ;
IN: game.models.obj

SINGLETON: obj-models
"obj" ascii obj-models register-models-class

<PRIVATE
SYMBOLS: v vt vn i ;

VERTEX-FORMAT: obj-vertex-format
    { "POSITION" float-components 3 f }
    { "TEXCOORD" float-components 2 f }
    { "NORMAL"   float-components 3 f } ;

: string>floats ( x -- y )
    [ string>float ] map ;

: string>faces ( x -- y )
    [ "/" split [ string>number ] map ] map ;

: 3face>aos ( x -- y )
    dup length {
        { 3
          [
              first3
              [ 1 - v get nth ]
              [ 1 - vt get nth ]
              [ 1 - vn get nth ] tri* 3array flatten
          ] }
        { 2
          [
              first2
              [ 1 - v get nth ]
              [ 1 - vt get nth ] bi* 2array flatten
          ] }
    } case ;
          

: 4face>aos ( x -- y z )
    [ 3 head [ 3face>aos 1array ] map ]
    [ [ 0 swap nth ] [ 2 swap nth ] [ 3 swap nth ] tri 3array [ 3face>aos 1array ] map ]
    bi
    ;

: faces>aos ( x -- y )
    dup length
    {
        { 3 [ [ 3face>aos 1array ] map 1array ] }
        { 4 [ 4face>aos 2array ] }
    } case ;

: push* ( x z -- y )
    [ push ] keep ;

: line>obj ( line -- )
    " \t\n" split harvest dup
    length 1 >
    [
        [ rest ] [ first ] bi
        {
            { "#" [ drop ] }
            { "v" [ string>floats 3 head v [ push* ] change ] }
            { "vt" [ string>floats 2 head vt [ push* ] change ] }
            { "vn" [ string>floats 3 head vn [ push* ] change ] }
            { "f" [ string>faces faces>aos [ [ i [ push* ] change ] each ] each ] }
            { "o" [ drop ] }
            { "g" [ drop ] }
            { "s" [ drop ] }
            { "mtllib" [ drop ] }
            { "usemtl" [ drop ] }
        } case
    ]
    [ drop ] if ;

PRIVATE>

M: obj-models stream>models
    drop
    [
        V{ }
        [ clone v set ]
        [ clone vt set ]
        [ clone vn set ] tri
        V{ } V{ } H{ } <indexed-seq> i set
    ] H{ } make-assoc 
    [
        [ line>obj ] each-stream-line i get
    ] bind
    [ dseq>> flatten >float-array ]
    [ iseq>> flatten >uint-array ] bi obj-vertex-format model boa 1array ;

