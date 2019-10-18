USING: accessors alien.c-types alien.handles euler.b-rep
game.models.half-edge grouping kernel locals opengl.gl
opengl.glu sequences specialized-arrays specialized-vectors
libc destructors alien.data ;
IN: euler.b-rep.triangulation

SPECIALIZED-ARRAY: double

ERROR: triangulated-face-must-be-base ;

<PRIVATE

: tess-begin ( -- callback )
    [| primitive-type vertices-h |
        primitive-type GL_TRIANGLES =
        [ "unexpected primitive type" throw ] unless
    ] GLUtessBeginDataCallback ;

: tess-end ( -- callback )
    [| vertices-h |
        ! nop
    ] GLUtessEndDataCallback ;

: tess-vertex ( -- callback )
    [| vertex-h vertices-h |
        vertex-h alien-handle-ptr>
        vertices-h alien-handle-ptr> push
    ] GLUtessVertexDataCallback ;

: tess-edge-flag ( -- callback )
    [| flag vertices-h |
        ! nop
    ] GLUtessEdgeFlagDataCallback ;

PRIVATE>

:: triangulate-face ( face -- triangles )
    [
        face dup base-face>> eq? [ triangulated-face-must-be-base ] unless

        gluNewTess &gluDeleteTess :> tess
        V{ } clone :> vertices
        vertices <alien-handle-ptr> &release-alien-handle-ptr :> vertices-h

        tess GLU_TESS_BEGIN_DATA     tess-begin     gluTessCallback
        tess GLU_TESS_END_DATA       tess-end       gluTessCallback
        tess GLU_TESS_VERTEX_DATA    tess-vertex    gluTessCallback
        tess GLU_TESS_EDGE_FLAG_DATA tess-edge-flag gluTessCallback

        tess vertices-h gluTessBeginPolygon

        4 double malloc-array &free :> vertex-buf

        face [| ring |
            tess gluTessBeginContour

            ring edge>> [
                tess swap vertex>>
                [ position>> double >c-array ]
                [ <alien-handle-ptr> &release-alien-handle-ptr ] bi gluTessVertex
            ] each-face-edge

            tess gluTessEndContour

            ring next-ring>> dup
        ] loop drop
        tess gluTessEndPolygon

        vertices { } like 3 <groups>
    ] with-destructors ;
