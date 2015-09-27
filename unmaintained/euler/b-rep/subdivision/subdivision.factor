USING: accessors arrays assocs euler.b-rep
game.models.half-edge kernel locals math math.vectors
math.vectors.simd.cords sequences sets typed fry ;
FROM: sequences.private => nth-unsafe set-nth-unsafe ;
IN: euler.b-rep.subdivision

: <vertex> ( position -- vertex ) vertex new swap >>position ; inline

: face-points ( faces -- face-pts )
    [ edge>> face-midpoint <vertex> ] map ; inline

:: edge-points ( edges edge-indices face-indices face-points -- edge-pts )
    edges length 0 <array> :> edge-pts

    edges [| edge n |
        edge opposite-edge>> :> opposite-edge
        opposite-edge edge-indices at :> opposite-n

        n opposite-n < [
            edge          vertex>> position>>
            opposite-edge vertex>> position>> v+
            edge          face>> face-indices at face-points nth position>> v+
            opposite-edge face>> face-indices at face-points nth position>> v+
            0.25 v*n
            <vertex>
            [ n edge-pts set-nth-unsafe ]
            [ opposite-n edge-pts set-nth-unsafe ] bi
        ] when
    ] each-index

    edge-pts ; inline

:: vertex-points ( vertices edge-indices face-indices edge-pts face-points -- vertex-pts )
    vertices [| vertex |
        0 double-4{ 0 0 0 0 } double-4{ 0 0 0 0 }
        vertex edge>> [| valence face-sum edge-sum edge |
            valence 1 +
            face-sum edge face>> face-indices at face-points nth position>> v+
            edge-sum edge next-edge>> vertex>> position>> v+
        ] each-vertex-edge :> ( valence face-sum edge-sum )
        valence >float :> fvalence
        face-sum fvalence v/n :> face-avg
        edge-sum fvalence v/n :> edge-avg
        face-avg  edge-avg v+  vertex position>> fvalence 2.0 - v*n v+
        fvalence v/n
        <vertex>
    ] map ; inline

TYPED:: subdivide ( brep: b-rep -- brep': b-rep )
    brep vertices>> :> vertices
    brep edges>>    :> edges
    brep faces>>    :> faces

    vertices >index-hash :> vertex-indices
    edges    >index-hash :> edge-indices
    faces    >index-hash :> face-indices

    faces face-points :> face-pts
    edges edge-indices face-indices face-pts edge-points :> edge-pts
    vertices edge-indices face-indices edge-pts face-pts vertex-points :> vertex-pts

    V{ } clone :> sub-edges
    V{ } clone :> sub-faces

    vertices [
        edge>> [| edg |
            edg edge-indices at edge-pts nth :> point-a
            edg next-edge>> :> next-edg
            next-edg vertex>> :> next-vertex
            next-vertex vertex-indices at vertex-pts nth :> point-b
            next-edg edge-indices at edge-pts nth :> point-c
            edg face>> face-indices at face-pts nth :> point-d

            face new
                dup >>base-face :> fac

            b-edge new
                fac >>face
                point-a >>vertex :> edg-a
            b-edge new
                fac >>face
                point-b >>vertex :> edg-b
            b-edge new
                fac >>face
                point-c >>vertex :> edg-c
            b-edge new
                fac >>face
                point-d >>vertex :> edg-d
            edg-a fac   edge<<
            edg-b edg-a next-edge<<
            edg-c edg-b next-edge<<
            edg-d edg-c next-edge<<
            edg-a edg-d next-edge<<

            fac sub-faces push
            edg-a sub-edges push
            edg-b sub-edges push
            edg-c sub-edges push
            edg-d sub-edges push

            point-a [ edg-a or ] change-edge drop
            point-b [ edg-b or ] change-edge drop
            point-c [ edg-c or ] change-edge drop
            point-d [ edg-d or ] change-edge drop
        ] each-vertex-edge
    ] each

    b-rep new
        sub-faces { } like >>faces
        sub-edges { } like >>edges
        face-pts edge-pts vertex-pts 3append members { } like >>vertices
    [ connect-opposite-edges ] keep ;
