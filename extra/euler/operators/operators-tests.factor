USING: accessors euler.operators euler.modeling euler.b-rep
kernel tools.test game.models.half-edge combinators namespaces
fry sequences make ;
FROM: euler.b-rep => has-rings? ;
IN: euler.operators.tests

{ t } [ [ ] make-b-rep b-rep? ] unit-test

{ } [
    [
        { 1 0 0 }
        { 0 1 0 }
        make-vefs
        {
            [ face-ccw vertex-pos { 1 0 0 } assert= ]
            [ vertex-pos { 0 1 0 } assert= ]
            [ vertex-valence 1 assert= ]
            [ face-ccw vertex-valence 1 assert= ]
            [ dup face-ccw assert-same-face ]
        } cleave
    ] make-b-rep check-b-rep
] unit-test

{ } [
    [
        { 1 0 0 }
        { 0 1 0 }
        make-vefs
        kill-vefs
    ] make-b-rep assert-empty-b-rep
] unit-test

[
    [
        { 1 0 0 }
        { 0 1 0 }
        make-vefs
        dup face-ccw
        { 0 0 1 } make-ev
    ] make-b-rep
] [ edges-not-incident? ] must-fail-with

{ } [
    [
        0
        1
        make-vefs
        dup 2 make-ev
        [ vertex-pos 2 assert= ]
        [ opposite-edge>> vertex-pos 1 assert= ]
        bi
    ] make-b-rep check-b-rep
] unit-test

{ } [
    [
        { 1 0 0 }
        { 0 1 0 }
        make-vefs
        dup dup { 0 0 1 } make-ev kill-ev
        kill-vefs
    ] make-b-rep assert-empty-b-rep
] unit-test

{ } [
    [
        { 1 2 3 } smooth-smooth polygon>double-face
        dup face-cw opposite-edge>>
        2dup [ "a" set ] [ "b" set ] bi*
        4 make-ev {
            [ face-sides 4 assert= ]
            [ vertex-pos 4 assert= ]
            [ opposite-edge>> face-sides 4 assert= ]
            [ face-ccw "b" get assert= ]
            [ face-cw "a" get opposite-edge>> assert= ]
        } cleave
    ] make-b-rep check-b-rep
] unit-test

{ } [
    [
        { 1 2 3 4 } smooth-smooth polygon>double-face
        [ face-ccw opposite-edge>> ]
        [ face-ccw face-ccw ]
        [ dup face-ccw face-ccw make-ef drop ] tri
        5 make-ev {
            [ vertex-pos 5 assert= ]
            [ face-sides 4 assert= ]
        } cleave
    ] make-b-rep check-b-rep
] unit-test

{ } [
    [
        { 1 0 0 }
        { 0 1 0 }
        make-vefs
        [
            dup dup make-ef
            [ face>> ] bi@ eq? f assert=
        ]
        [ vertex-valence 3 assert= ]
        bi
    ] make-b-rep check-b-rep
] unit-test

[
    [
        { 1 0 0 }
        { 0 1 0 }
        make-vefs
        dup dup make-ef make-ef
    ] make-b-rep
] [ edges-in-different-faces? ] must-fail-with

{ } [
    [
        { 1 0 0 }
        { 0 1 0 }
        make-vefs
        dup opposite-edge>>
        [ [ "a" set ] [ "b" set ] bi* ]
        [
            make-ef
            {
                [ vertex-valence 2 assert= ]
                [ opposite-edge>> vertex-valence 2 assert= ]
                [ next-edge>> "a" get assert= ]
                [ opposite-edge>> next-edge>> "b" get assert= ]
                [ dup opposite-edge>> [ face>> ] bi@ eq? f assert= ]
            } cleave
        ] 2bi
    ] make-b-rep check-b-rep
] unit-test

{ } [
    [
        { 1 2 3 4 } smooth-smooth polygon>double-face
        { 5 6 7 8 } smooth-smooth polygon>double-face
        { 9 10 11 12 } smooth-smooth polygon>double-face
        {
            [ [ drop ] dip kill-f-make-rh ]
            [ [ drop ] 2dip kill-f-make-rh ]
            [ [ drop ] dip [ face>> ] bi@ [ base-face>> ] dip assert= ]
            [ [ drop ] 2dip [ face>> ] bi@ [ base-face>> ] dip assert= ]
            [ 2nip face>> has-rings? t assert= ]
            [ drop drop make-f-kill-rh ]
            [ drop nip make-f-kill-rh ]
            [ drop drop face>> dup base-face>> assert= ]
            [ drop nip face>> dup base-face>> assert= ]
            [ 2nip face>> has-rings? f assert= ]
        } 3cleave
    ] make-b-rep check-b-rep
] unit-test

{
    { 0 1 0 }
    { 1 0 0 }
    { 1 2 1 }
    { 2 1 1 }
} [
    [
        { 1 0 0 }
        { 0 1 0 }
        make-vefs
        dup opposite-edge>>
        {
            [ [ vertex-pos ] bi@ ]
            [ drop { 1 1 1 } move-e ]
            [ [ vertex-pos ] bi@ ]
        } 2cleave
    ] make-b-rep check-b-rep
] unit-test

{
    {
        { 2 1 1 }
        { 1 2 1 }
        { 1 1 2 }
    }
} [
    [
        { { 1 0 0 } { 0 1 0 } { 0 0 1 } } smooth-smooth polygon>double-face
        [ { 1 1 1 } move-f ]
        [ [ [ vertex-pos , ] each-face-edge ] { } make ]
        bi
    ] make-b-rep check-b-rep
] unit-test

! Make sure we update the face's edge when killing an edge
{ } [
    [
        { 1 2 3 4 } smooth-smooth polygon>double-face
        kill-ev
    ] make-b-rep check-b-rep
] unit-test

{ } [
    [
        { 1 2 3 4 } smooth-smooth polygon>double-face
        face-ccw kill-ev
    ] make-b-rep check-b-rep
] unit-test

{ } [
    [
        { 1 2 3 4 } smooth-smooth polygon>double-face
        face-ccw face-ccw kill-ev
    ] make-b-rep check-b-rep
] unit-test

{ } [
    [
        { 1 2 3 4 } smooth-smooth polygon>double-face
        face-ccw face-ccw face-ccw kill-ev
    ] make-b-rep check-b-rep
] unit-test
