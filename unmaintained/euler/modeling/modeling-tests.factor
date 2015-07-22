USING: accessors kernel tools.test euler.b-rep euler.operators
euler.modeling game.models.half-edge ;
IN: euler.modeling.tests

! polygon>double-face
{ } [
    [
        { { -1 -1 0 } { 1 -1 0 } { 1 1 0 } { -1 1 0 } }
        smooth-smooth polygon>double-face
        [ face-sides 4 assert= ]
        [ opposite-edge>> face-sides 4 assert= ]
        [ face-normal { 0.0 0.0 1.0 } assert= ]
        tri
    ] make-b-rep check-b-rep
] unit-test

! extrude-simple
{ } [
    [
        { { -1 -1 0 } { 1 -1 0 } { 1 1 0 } }
        smooth-smooth polygon>double-face
        1 f extrude-simple
        [ face-sides 3 assert= ]
        [ opposite-edge>> face-sides 4 assert= ]
        bi
    ] make-b-rep check-b-rep
] unit-test

! project-pt-line
{ {  0 1 0 } } [ {  0 0 0 } { 0 1 0 } { 1 1 0 } project-pt-line ] unit-test
{ {  0 1 0 } } [ {  0 0 0 } { 1 1 0 } { 0 1 0 } project-pt-line ] unit-test
{ {  0 1 0 } } [ {  0 0 0 } { 2 1 0 } { 1 1 0 } project-pt-line ] unit-test
{ { -1 1 0 } } [ { -1 0 0 } { 2 1 0 } { 1 1 0 } project-pt-line ] unit-test
{ { 1/2 1/2 0 } } [ {  0 0 0 } { 0 1 0 } { 1 0 0 } project-pt-line ] unit-test

! project-pt-plane
{ {  0  0  1 } } [ { 0 0 0 } { 0 0 1 } { 0 0  1 } -1 project-pt-plane ] unit-test
{ {  0  0 -1 } } [ { 0 0 0 } { 0 0 1 } { 0 0  1 }  1 project-pt-plane ] unit-test
{ {  0  0  3 } } [ { 0 0 0 } { 0 0 1 } { 0 0  1 } -3 project-pt-plane ] unit-test
{ {  0  0  3 } } [ { 0 0 0 } { 0 0 1 } { 0 0 -1 }  3 project-pt-plane ] unit-test
{ {  0  0  1 } } [ { 0 0 0 } { 0 0 1 } { 0 1  1 } -1 project-pt-plane ] unit-test

{ { 0 2/3 1/3 } } [ { 0 0 0 } { 0 2 1 } { 0 1  1 } -1 project-pt-plane ] unit-test

{ {  0  0  1 } } [ { 0 0 0 } { 0 0   1/2 } { 0 0 1 } -1 project-pt-plane ] unit-test
{ {  0  1  1 } } [ { 0 0 0 } { 0 1/2 1/2 } { 0 0 1 } -1 project-pt-plane ] unit-test
