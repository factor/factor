! Copyright (C) 2010 Erik Charlebois
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs grouping hashtables kernel
locals math math.parser sequences sequences.deep
specialized-arrays.instances.alien.c-types.float
specialized-arrays.instances.alien.c-types.uint splitting xml
xml.data xml.traversal math.order

combinators
images
gpu.shaders
io prettyprint
;
IN: collada

TUPLE: model attribute-buffer index-buffer vertex-format ;
TUPLE: source semantic offset data ;

:: collect-sources ( sources vertices inputs -- sources )
    inputs
    [| input |
        input "source" attr rest vertices first =
        [
            vertices second [| vertex |
                vertex first
                input "offset" attr string>number
                vertex second rest sources at source boa
            ] map
        ]
        [
            input [ "semantic" attr ]
                  [ "offset" attr string>number ]
                  [ "source" attr rest sources at ] tri source boa
        ] if
    ] map flatten ;

: string>numbers ( string -- number-seq )
    " \t\n" split [ string>number ] map ; inline

: x/ ( x x -- x ) tag-named ; inline
: x@ ( x x -- x ) attr ; inline
: xt ( x -- x ) children>string ; inline

: map-tags-named ( tag string quot -- seq )
    [ tags-named ] dip map ; inline

SINGLETONS: x-up y-up z-up ;
GENERIC: up-axis-swizzle! ( from-axis seq -- seq )
M: x-up up-axis-swizzle!
    drop dup
    [
        [ 0 swap nth neg ]
        [ 1 swap nth ]
        [ 2 swap nth ] tri
        swap -rot 
    ] [
        [ 2 swap set-nth ]
        [ 1 swap set-nth ]
        [ 0 swap set-nth ] tri
    ] bi ;
M: y-up up-axis-swizzle! drop ;
M: z-up up-axis-swizzle!
    drop dup
    [
        [ 0 swap nth ]
        [ 1 swap nth ]
        [ 2 swap nth neg ] tri
        swap
    ] [
        [ 2 swap set-nth ]
        [ 1 swap set-nth ]
        [ 0 swap set-nth ] tri
    ] bi ;
    
: source>array ( source-tag up-axis scale -- array )
    rot
    [ "float_array" x/ xt string>numbers [ * ] with map ]
    [ nip "technique_common" x/ "accessor" x/ "stride" x@ string>number ] 2bi
    <groups>
    [ swap up-axis-swizzle! ] with map ;

:: collada-mesh>model ( mesh-tag -- models )
    mesh-tag "source" [
        [ "id" x@ ]
        [ 
            [ "float_array" x/ xt string>numbers ]
            [ "technique_common" x/ "accessor" x/ "stride" x@ string>number ] bi <groups>
        ] bi 2array
    ] map-tags-named >hashtable :> sources

    mesh-tag "vertices" tag-named
    [ "id" attr ] 
    [
        "input" tags-named [
            [ "semantic" attr ] [ "source" attr ] bi 2array
        ] map
    ]
    bi 2array :> vertices

    mesh-tag "triangles" tags-named
    [| triangle |
        triangle "count" attr string>number                                        :> count
        sources vertices triangle "input" tags-named collect-sources               :> flattened-sources
        triangle "p" tag-named children>string " \t\n" split [ string>number ] map :> indices
        flattened-sources [ offset>> ] [ max ] map-reduce                          :> max-offset
        indices dup length count / <groups> [ max-offset 1 + <groups> ] map        :> triangles-indices

        V{ } clone :> index-buffer
        V{ } clone :> attribute-buffer
        V{ } clone :> vertex-format
        H{ } clone :> inverse-attribute-buffer
        
        triangles-indices [
            [
                [| triangle-index triangle-offset |
                    triangle-index triangle-offset flattened-sources
                    [| index offset source |
                        source offset>> offset = [
                            index source data>> nth
                        ] [ f ] if 
                    ] with with map sift flatten :> blah
                    
                    blah inverse-attribute-buffer at [
                        index-buffer push
                    ] [
                        attribute-buffer length
                        [ blah inverse-attribute-buffer set-at ]
                        [ index-buffer push ] bi
                        blah attribute-buffer push
                    ] if*
                ] each-index
            ] each
        ] each

        attribute-buffer flatten >float-array
        index-buffer     flatten >uint-array
        flattened-sources [
            {
                [ semantic>> ]
                [ drop float-components ]
                [ data>> first length ]
                [ drop f ]
            } cleave vertex-attribute boa
        ] map
        model boa
    ] map
    
    ;
