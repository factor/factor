! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators euler.b-rep fry
game.models.half-edge grouping io kernel locals math
math.parser math.vectors.simd.cords sequences splitting ;
IN: euler.b-rep.io.obj

<PRIVATE
: write-obj-vertex ( vertex -- )
    "v " write
    position>> 3 head-slice [ bl ] [ number>string write ] interleave nl ;

: write-obj-face ( face vx-indices -- )
    "f" write
    [ edge>> ] dip '[ bl vertex>> _ at 1 + number>string write ] each-face-edge nl ;
PRIVATE>

:: write-obj ( b-rep -- )
    b-rep vertices>> :> vertices
    vertices >index-hash :> vx-indices

    vertices [ write-obj-vertex ] each
    b-rep faces>> [ vx-indices write-obj-face ] each ;

<PRIVATE
:: reconstruct-face ( face-vertices vertices -- face edges )
    face new
        dup >>base-face
        :> face
    face-vertices [
        vertices nth :> vertex
        b-edge new
            vertex >>vertex
            face >>face
            :> edge
        vertex [ [ edge ] unless* ] change-edge drop
        edge
    ] { } map-as :> edges

    edges 1 edges length 1 + edges <circular-slice> [ >>next-edge drop ] 2each
    face edges first >>edge
    edges ;

:: reconstruct-b-rep ( vertex-positions faces-vertices -- b-rep )
    vertex-positions [ vertex new swap >>position ] { } map-as :> vertices
    V{ } clone :> edges
    faces-vertices [ vertices reconstruct-face edges push-all ] { } map-as :> faces

    b-rep new
        faces >>faces
        edges >>edges
        vertices >>vertices
    dup connect-opposite-edges ;

: parse-vertex ( line -- position )
    split-words first3 [ string>number >float ] tri@ 0.0 double-4-boa ;

: read-vertex ( line vertices -- )
    [ parse-vertex ] dip push ;

: parse-face-index ( token vertices -- index )
    swap "/" split1 drop string>number
    dup 0 >= [ nip 1 - ] [ [ length ] dip + ] if ;

: parse-face ( line vertices -- vertices )
    [ split-words ] dip '[ _ parse-face-index ] map ;

: read-face ( line vertices faces -- )
    [ parse-face ] dip push ;

PRIVATE>

:: (read-obj) ( -- vertices faces )
    V{ } clone :> vertices
    V{ } clone :> faces
    [
        " " split1 swap {
            { "#" [ drop ] }
            { "v" [ vertices read-vertex ] }
            { "f" [ vertices faces read-face ] }
            [ 2drop ]
        } case
    ] each-line
    vertices faces ;

:: read-obj ( -- b-rep )
    (read-obj) reconstruct-b-rep ;
