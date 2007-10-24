! Factor port of the raytracer benchmark from
! http://www.ffconsultancy.com/free/ray_tracer/languages.html

USING: float-arrays compiler generic io io.files kernel math
math.functions math.vectors math.parser namespaces sequences
sequences.private words ;
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

TUPLE: ray orig dir ;

C: <ray> ray

TUPLE: hit normal lambda ;

C: <hit> hit

GENERIC: intersect-scene ( hit ray scene -- hit )

TUPLE: sphere center radius ;

C: <sphere> sphere

: sphere-v ( sphere ray -- v )
    swap sphere-center swap ray-orig v- ; inline

: sphere-b ( ray v -- b ) swap ray-dir v. ; inline

: sphere-disc ( sphere v b -- d )
    sq swap norm-sq - swap sphere-radius sq + ; inline

: -+ ( x y -- x-y x+y ) [ - ] 2keep + ; inline

: sphere-b/d ( b d -- t )
    -+ dup 0.0 < [ 2drop 1.0/0.0 ] [ >r [ 0.0 > ] keep r> ? ] if ; inline

: ray-sphere ( sphere ray -- t )
    2dup sphere-v tuck sphere-b [ sphere-disc ] keep
    over 0.0 < [ 2drop 1.0/0.0 ] [ swap sqrt sphere-b/d ] if ;
    inline

: sphere-n ( ray sphere l -- n )
    pick ray-dir n*v swap sphere-center v- swap ray-orig v+ ;
    inline

: if-ray-sphere ( hit ray sphere quot -- hit )
    #! quot: hit ray sphere l -- hit
    >r pick hit-lambda >r 2dup swap ray-sphere dup r> >=
    [ 3drop ] r> if ; inline

M: sphere intersect-scene ( hit ray sphere -- hit )
    [ [ sphere-n normalize ] keep <hit> nip ] if-ray-sphere ;

TUPLE: group objs ;

: <group> ( objs bound -- group )
    { set-group-objs set-delegate } group construct ;

: make-group ( bound quot -- )
    swap >r { } make r> <group> ; inline

M: group intersect-scene ( hit ray group -- hit )
    [
        drop
        group-objs [ >r tuck r> intersect-scene swap ] each
        drop
    ] if-ray-sphere ;

: initial-hit T{ hit f F{ 0.0 0.0 0.0 } 1.0/0.0 } ; inline

: initial-intersect ( ray scene -- hit )
    initial-hit -rot intersect-scene ; inline

: ray-o ( ray hit -- o )
    over ray-dir over hit-lambda v*n
    swap hit-normal delta v*n v+
    swap ray-orig v+ ; inline

: sray-intersect ( ray scene hit -- ray )
    swap >r ray-o light vneg <ray> r> initial-intersect ; inline

: ray-g ( hit -- g ) hit-normal light v. ; inline

: cast-ray ( ray scene -- g )
    2dup initial-intersect dup hit-lambda 1.0/0.0 = [
        3drop 0.0
    ] [
        dup ray-g >r sray-intersect hit-lambda 1.0/0.0 =
        [ r> neg ] [ r> drop 0.0 ] if
    ] if ; inline

: create-center ( c r d -- c2 )
    >r 3.0 12.0 sqrt / * r> n*v v+ ; inline

DEFER: create ( level c r -- scene )

: create-step ( level c r d -- scene )
    over >r create-center r> 2.0 / >r >r 1 - r> r> create ;

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
        [ >r 3dup r> create-step , ] create-offsets 3drop
    ] make-group ;

: create ( level c r -- scene )
    pick 1 = [ <sphere> nip ] [ create-group ] if ;

: ss-point ( dx dy -- point )
    [ oversampling /f ] 2apply 0.0 3float-array ;

: ss-grid ( -- ss-grid )
    oversampling [ oversampling [ ss-point ] curry* map ] map ;

: ray-grid ( point ss-grid -- ray-grid )
    [
        [ v+ normalize { 0.0 0.0 -4.0 } swap <ray> ] curry* map
    ] curry* map ;

: ray-pixel ( scene point -- n )
    ss-grid ray-grid 0.0 -rot
    [ [ swap cast-ray + ] curry* each ] curry* each ;

: pixel-grid ( -- grid )
    size reverse [
        size [
            [ size 0.5 * - ] 2apply swap size
            3float-array
        ] curry* map
    ] map ;

: pgm-header ( w h -- )
    "P5\n" % swap # " " % # "\n255\n" % ;

: pgm-pixel ( n -- ) 255 * 0.5 + >fixnum , ;

: ray-trace ( scene -- pixels )
    pixel-grid [ [ ray-pixel ] curry* map ] curry* map ;

: run ( -- string )
    levels { 0.0 -1.0 0.0 } 1.0 create ray-trace [
        size size pgm-header
        [ [ oversampling sq / pgm-pixel ] each ] each
    ] "" make ;

: raytracer-main
    "raytracer.pnm" resource-path
    <file-writer> [ run write ] with-stream ;

MAIN: raytracer-main
