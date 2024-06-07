! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays assocs grouping
hashtables kernel locals math math.parser sequences sequences.deep
splitting xml xml.data xml.traversal math.order namespaces
combinators images gpu.shaders io make game.models game.models.util
io.encodings.ascii game.models.loader specialized-arrays ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAYS: c:float c:uint ;
IN: game.models.collada

SINGLETON: collada-models
"dae" ascii collada-models register-models-class

ERROR: missing-attr tag attr ;
ERROR: missing-child tag child-name ;

<PRIVATE
TUPLE: source semantic offset data ;
SYMBOLS: up-axis unit-ratio ;

: string>numbers ( string -- number-seq )
    " \t\n" split harvest [ string>number ] map ;

: x/ ( tag child-name -- child-tag )
    [ tag-named ]
    [ rot dup [ drop missing-child ] unless 2nip ]
    2bi ; inline

: x@ ( tag attr-name -- attr-value )
    [ attr ]
    [ rot dup [ drop missing-attr ] unless 2nip ]
    2bi ; inline

: xt ( tag -- content ) children>string ;

: x* ( tag child-name quot -- seq )
    [ tags-named ] dip map ; inline

SINGLETONS: x-up y-up z-up ;
UNION: rh-up x-up y-up z-up ;

GENERIC: >y-up-axis! ( seq from-axis -- seq )
M: x-up >y-up-axis!
    drop dup
    [
        [ 0 swap nth ]
        [ 1 swap nth neg ]
        [ 2 swap nth ] tri
        swapd
    ] [
        [ 2 swap set-nth ]
        [ 1 swap set-nth ]
        [ 0 swap set-nth ] tri
    ] bi ;
M: y-up >y-up-axis! drop ;
M: z-up >y-up-axis!
    drop dup
    [
        [ 0 swap nth ]
        [ 1 swap nth neg ]
        [ 2 swap nth ] tri
        swap
    ] [
        [ 2 swap set-nth ]
        [ 1 swap set-nth ]
        [ 0 swap set-nth ] tri
    ] bi ;

: source>sequence ( source-tag up-axis scale -- sequence )
    rot
    [ "float_array" x/ xt string>numbers [ * ] with map ]
    [ nip "technique_common" x/ "accessor" x/ "stride" x@ string>number ] 2bi
    group
    [ tuck length 2 > [ >y-up-axis! ] [ drop ] if ] with map ;

: source>pair ( source-tag -- pair )
    [ "id" x@ ]
    [ up-axis get unit-ratio get source>sequence ] bi 2array ;

: mesh>sources ( mesh-tag -- hashtable )
    "source" [ source>pair ] x* >hashtable ;

: mesh>vertices ( mesh-tag -- pair )
    "vertices" x/
    [ "id" x@ ]
    [ "input"
      [
          [ "semantic" x@ ]
          [ "source" x@ ] bi 2array
      ] x*
    ] bi 2array ;

:: collect-sources ( sources vertices inputs -- seq )
    inputs
    [| input |
        input "source" x@ rest vertices first =
        [
            vertices second [| vertex |
                vertex first
                input "offset" x@ string>number
                vertex second rest sources at source boa
            ] map
        ]
        [
            input [ "semantic" x@ ]
                  [ "offset" x@ string>number ]
                  [ "source" x@ rest sources at ] tri source boa
        ] if
    ] map flatten ;

: group-indices ( index-stride triangle-count indices -- grouped-indices )
    dup length rot / group swap [ group ] curry map ;

: triangles>numbers ( triangles-tag -- number-seq )
    "p" x/ children>string " \t\n" split [ string>number ] map ;

: largest-offset+1 ( source-seq -- largest-offset+1 )
    [ offset>> ] [ max ] map-reduce 1 + ;

VERTEX-FORMAT: collada-vertex-format
    { "POSITION" float-components 3 f }
    { "NORMAL" float-components 3 f }
    { "TEXCOORD" float-components 2 f } ;

: pack-attributes ( source-indices sources -- attributes )
    [
        [
            [
                [ data>> ] [ offset>> ] bi
                rot = [ nth ] [ 2drop f ] if
            ] 2with map sift flatten ,
        ] curry each-index
    ] V{ } make flatten ;

:: soa>aos ( triangles-indices sources -- attribute-buffer index-buffer )
    [ triangles-indices [ [ sources pack-attributes , ] each ] each ]
    V{ } V{ } H{ } <indexed-seq> make [ dseq>> ] [ iseq>> ] bi ;

: triangles>model ( sources vertices triangles-tag -- model )
    [ "input" tags-named collect-sources ] guard

    [
        largest-offset+1 swap
        [ "count" x@ string>number ] [ triangles>numbers ] bi
        group-indices
    ]
    [
        soa>aos
        [ flatten c:float >c-array ]
        [ flatten c:uint >c-array ]
        bi* collada-vertex-format f model boa
    ] bi ;

: mesh>triangles ( sources vertices mesh-tag -- models )
    "triangles" tags-named [ triangles>model ] 2with map ;

: mesh>models ( mesh-tag -- models )
    [
        { { up-axis y-up } { unit-ratio 1 } } [
            mesh>sources
        ] with-variables
    ]
    [ mesh>vertices ]
    [ mesh>triangles ] tri ;
PRIVATE>

M: collada-models stream>models
    drop read-xml "mesh" deep-tags-named [ mesh>models ] map flatten ;
