USING: accessors euler.b-rep euler.modeling euler.operators
euler.b-rep.examples kernel locals math.vectors.simd.cords
namespaces sequences tools.test ;
IN: euler.b-rep.tests

{ double-4{ 0.0 0.0 -1.0 0.0 } }
[ valid-cube-b-rep edges>> first face-normal ] unit-test

{ double-4{ 0.0 0.0 -1.0 0.0 } -1.0 }
[ valid-cube-b-rep edges>> first face-plane ] unit-test

{ t } [ 0 multi-ringed-face-cube-b-rep faces>> nth base-face? ] unit-test
{ t } [ 5 multi-ringed-face-cube-b-rep faces>> nth base-face? ] unit-test
{ f } [ 6 multi-ringed-face-cube-b-rep faces>> nth base-face? ] unit-test

:: mock-face ( p0 p1 p2 -- edge )
    b-edge new vertex new p0 >>position >>vertex :> e0
    b-edge new vertex new p1 >>position >>vertex :> e1
    b-edge new vertex new p2 >>position >>vertex :> e2

    e1 e0 next-edge<<
    e2 e1 next-edge<<
    e0 e2 next-edge<<

    e0 ;

{
    double-4{
        0x1.279a74590331dp-1
        0x1.279a74590331dp-1
        0x1.279a74590331dp-1
        0.0
    }
    -0x1.bb67ae8584cabp1
} [
    double-4{ 1 0 5 0 }
    double-4{ 0 1 5 0 }
    double-4{ 0 0 6 0 } mock-face face-plane
] unit-test

V{ t } clone sharpness-stack [
    [ t ] [ get-sharpness ] unit-test
    [ V{ f } ] [ f set-sharpness sharpness-stack get ] unit-test
    [ V{ f t } t ] [ t push-sharpness sharpness-stack get get-sharpness ] unit-test
    [ t V{ f } f ] [ pop-sharpness sharpness-stack get get-sharpness ] unit-test
] with-variable

{ t } [ valid-cube-b-rep [ edges>> first ] keep is-valid-edge? ] unit-test
{ f } [ b-edge new valid-cube-b-rep is-valid-edge? ] unit-test

{ t } [
    valid-cube-b-rep edges>>
    [ [  0 swap nth ] [  1 swap nth ] bi connecting-edge ]
    [    0 swap nth ] bi eq?
] unit-test

{ t } [
    valid-cube-b-rep edges>>
    [ [  1 swap nth ] [  0 swap nth ] bi connecting-edge ]
    [    6 swap nth ] bi eq?
] unit-test

{ t } [
    valid-cube-b-rep edges>>
    [ [  0 swap nth ] [  3 swap nth ] bi connecting-edge ]
    [   21 swap nth ] bi eq?
] unit-test

{ f } [
    valid-cube-b-rep edges>>
    [  0 swap nth ] [  2 swap nth ] bi connecting-edge
] unit-test

{ double-4{ 0 0 -1 0 } } [
    [
        { double-4{ 0 0 0 0 } double-4{ 0 1 0 0 } double-4{ 0 2 0 0 } double-4{ 1 1 0 0 } }
        smooth-smooth polygon>double-face face-normal
    ] make-b-rep drop
] unit-test
