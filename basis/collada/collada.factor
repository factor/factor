! Copyright (C) 2010 Erik Charlebois
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs grouping hashtables kernel
locals math math.parser sequences sequences.deep
specialized-arrays.instances.alien.c-types.float
specialized-arrays.instances.alien.c-types.uint splitting xml
xml.data xml.traversal math.order
namespaces combinators images gpu.shaders io ;
IN: collada

TUPLE: model attribute-buffer index-buffer vertex-format ;
TUPLE: source semantic offset data ;

SYMBOLS: up-axis unit-ratio ;

ERROR: missing-attr tag attr ;
ERROR: missing-child tag child-name ;

: string>numbers ( string -- number-seq )
    " \t\n" split [ string>number ] map ;

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
        swap -rot 
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

: source>seq ( source-tag up-axis scale -- sequence )
    rot
    [ "float_array" x/ xt string>numbers [ * ] with map ]
    [ nip "technique_common" x/ "accessor" x/ "stride" x@ string>number ] 2bi
    <groups>
    [ swap >y-up-axis! ] with map ;

: source>pair ( source-tag -- pair )
    [ "id" x@ ]
    [ up-axis get unit-ratio get source>seq ] bi 2array ;

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

:: collect-sources ( sources vertices inputs -- sources )
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
    dup length rot / <groups> swap [ <groups> ] curry map ;

: triangles>numbers ( triangles-tag -- number-seq )
    "p" x/ children>string " \t\n" split [ string>number ] map ;

: largest-offset+1 ( source-seq -- largest-offset+1 )
    [ offset>> ] [ max ] map-reduce 1 + ;

: <model> ( attribute-buffer index-buffer sources -- model )
    [ flatten >float-array ]
    [ flatten >uint-array ]
    [
        [
            {
                [ semantic>> ]
                [ drop float-components ]
                [ data>> first length ]
                [ drop f ]
            } cleave vertex-attribute boa
        ] map
    ] tri* model boa ;

:: soa>aos ( triangles-indices sources -- attribute-buffer index-buffer )
    V{ } clone :> attribute-buffer
    V{ } clone :> index-buffer
    H{ } clone :> inverse-attribute-buffer
    triangles-indices [
        [
            [| triangle-index triangle-offset |
                triangle-index triangle-offset sources
                [| index offset source |
                    source offset>> offset = [
                        index source data>> nth
                    ] [ f ] if 
                ] with with map sift flatten :> attributes
                
                attributes inverse-attribute-buffer at [
                    index-buffer push
                ] [
                    attribute-buffer length
                    [ attributes inverse-attribute-buffer set-at ]
                    [ index-buffer push ] bi
                    attributes attribute-buffer push
                ] if*
            ] each-index
        ] each
    ] each
    attribute-buffer index-buffer ;

: triangles>model ( sources vertices triangles-tag -- model )
    [ "input" tags-named collect-sources ] keep swap
    
    [
        largest-offset+1 swap
        [ "count" x@ string>number ] [ triangles>numbers ] bi
        group-indices
    ]
    [
        [ soa>aos ] keep <model>
    ] bi ;
    
: mesh>triangles ( sources vertices mesh-tag -- models )
    "triangles" tags-named [ triangles>model ] with with map ;

: mesh>models ( mesh-tag -- models )
    [
        { { up-axis z-up } { unit-ratio 0.5 } } [
            mesh>sources
        ] bind
    ]
    [ mesh>vertices ]
    [ mesh>triangles ] tri ;
