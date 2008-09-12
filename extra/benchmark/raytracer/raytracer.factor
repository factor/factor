! Factor port of the raytracer benchmark from
! http://www.ffconsultancy.com/free/ray_tracer/languages.html

USING: arrays accessors float-arrays io io.files
io.encodings.binary kernel math math.functions math.vectors
math.parser make sequences sequences.private words ;
IN: benchmark.raytracer

! parameters
: light
    #! Normalized { -1 -3 2 }.
    F{
        -0.2672612419124244
        -0.8017837257372732
        0.5345224838248488
    } ; inline

: oversampling 4 ; inline

: levels 3 ; inline

: size 200 ; inline

: delta 1.4901161193847656E-8 ; inline

TUPLE: ray { orig float-array read-only } { dir float-array read-only } ;

C: <ray> ray

TUPLE: hit { normal float-array read-only } { lambda float read-only } ;

C: <hit> hit

GENERIC: intersect-scene ( hit ray scene -- hit )

TUPLE: sphere { center float-array read-only } { radius float read-only } ;

C: <sphere> sphere

: sphere-v ( sphere ray -- v )
    swap center>> swap orig>> v- ; inline

: sphere-b ( ray v -- b ) swap dir>> v. ; inline

: sphere-disc ( sphere v b -- d )
    sq swap norm-sq - swap radius>> sq + ; inline

: -+ ( x y -- x-y x+y ) [ - ] 2keep + ; inline

: sphere-b/d ( b d -- t )
    -+ dup 0.0 <
    [ 2drop 1.0/0.0 ] [ [ [ 0.0 > ] keep ] dip ? ] if ; inline

: ray-sphere ( sphere ray -- t )
    2dup sphere-v tuck sphere-b [ sphere-disc ] keep
    over 0.0 < [ 2drop 1.0/0.0 ] [ swap sqrt sphere-b/d ] if ;
    inline

: sphere-n ( ray sphere l -- n )
    pick dir>> n*v swap center>> v- swap orig>> v+ ;
    inline

: if-ray-sphere ( hit ray sphere quot -- hit )
    #! quot: hit ray sphere l -- hit
    [
        pick lambda>> [ 2dup swap ray-sphere dup ] dip >=
        [ 3drop ]
    ] dip if ; inline

M: sphere intersect-scene ( hit ray sphere -- hit )
    [ [ sphere-n normalize ] keep <hit> nip ] if-ray-sphere ;

TUPLE: group < sphere { objs array read-only } ;

: <group> ( objs bound -- group )
    [ center>> ] [ radius>> ] bi rot group boa ; inline

: make-group ( bound quot -- )
    swap [ { } make ] dip <group> ; inline

M: group intersect-scene ( hit ray group -- hit )
    [
        drop
        objs>> [ [ tuck ] dip intersect-scene swap ] each
        drop
    ] if-ray-sphere ;

: initial-hit T{ hit f F{ 0.0 0.0 0.0 } 1.0/0.0 } ; inline

: initial-intersect ( ray scene -- hit )
    initial-hit -rot intersect-scene ; inline

: ray-o ( ray hit -- o )
    over dir>> over lambda>> v*n
    swap normal>> delta v*n v+
    swap orig>> v+ ; inline

: sray-intersect ( ray scene hit -- ray )
    swap [ ray-o light vneg <ray> ] dip initial-intersect ; inline

: ray-g ( hit -- g ) normal>> light v. ; inline

: cast-ray ( ray scene -- g )
    2dup initial-intersect dup lambda>> 1.0/0.0 = [
        3drop 0.0
    ] [
        [ sray-intersect lambda>> 1.0/0.0 = ] keep swap
        [ ray-g neg ] [ drop 0.0 ] if
    ] if ; inline

: create-center ( c r d -- c2 )
    [ 3.0 12.0 sqrt / * ] dip n*v v+ ; inline

DEFER: create ( level c r -- scene )

: create-step ( level c r d -- scene )
    over [ create-center ] dip 2.0 / [ 1 - ] 2dip create ;

: create-offsets ( quot -- )
    {
        F{ -1.0 1.0 -1.0 }
        F{ 1.0 1.0 -1.0 }
        F{ -1.0 1.0 1.0 }
        F{ 1.0 1.0 1.0 }
    } swap each ; inline

: create-bound ( c r -- sphere ) 3.0 * <sphere> ;

: create-group ( level c r -- scene )
    2dup create-bound [
        2dup <sphere> ,
        [ [ 3dup ] dip create-step , ] create-offsets 3drop
    ] make-group ;

: create ( level c r -- scene )
    pick 1 = [ <sphere> nip ] [ create-group ] if ;

: ss-point ( dx dy -- point )
    [ oversampling /f ] bi@ 0.0 3float-array ;

: ss-grid ( -- ss-grid )
    oversampling [ oversampling [ ss-point ] with map ] map ;

: ray-grid ( point ss-grid -- ray-grid )
    [
        [ v+ normalize F{ 0.0 0.0 -4.0 } swap <ray> ] with map
    ] with map ;

: ray-pixel ( scene point -- n )
    ss-grid ray-grid 0.0 -rot
    [ [ swap cast-ray + ] with each ] with each ;

: pixel-grid ( -- grid )
    size reverse [
        size [
            [ size 0.5 * - ] bi@ swap size
            3float-array
        ] with map
    ] map ;

: pgm-header ( w h -- )
    "P5\n" % swap # " " % # "\n255\n" % ;

: pgm-pixel ( n -- ) 255 * 0.5 + >fixnum , ;

: ray-trace ( scene -- pixels )
    pixel-grid [ [ ray-pixel ] with map ] with map ;

: run ( -- string )
    levels F{ 0.0 -1.0 0.0 } 1.0 create ray-trace [
        size size pgm-header
        [ [ oversampling sq / pgm-pixel ] each ] each
    ] B{ } make ;

: raytracer-main ( -- )
    run "raytracer.pnm" temp-file binary set-file-contents ;

MAIN: raytracer-main
