! Factor port of the raytracer benchmark from
! http://www.ffconsultancy.com/free/ray_tracer/languages.html
USING: arrays accessors specialized-arrays io
io.files io.files.temp io.encodings.binary kernel math
math.constants math.functions math.vectors math.parser make
sequences sequences.private words hints ;
FROM: alien.c-types => double ;
SPECIALIZED-ARRAY: double
IN: benchmark.raytracer

! parameters

! Normalized { -1 -3 2 }.
CONSTANT: light
    double-array{
        -0.2672612419124244
        -0.8017837257372732
        0.5345224838248488
    }

CONSTANT: oversampling 4

CONSTANT: levels 3

CONSTANT: size 200

: delta ( -- n ) epsilon sqrt ; inline

TUPLE: ray { orig double-array read-only } { dir double-array read-only } ;

C: <ray> ray

TUPLE: hit { normal double-array read-only } { lambda float read-only } ;

C: <hit> hit

GENERIC: intersect-scene ( hit ray scene -- hit )

TUPLE: sphere { center double-array read-only } { radius float read-only } ;

C: <sphere> sphere

: sphere-v ( sphere ray -- v )
    [ center>> ] [ orig>> ] bi* v- ; inline

: sphere-b ( v ray -- b )
    dir>> vdot ; inline

: sphere-d ( sphere b v -- d )
    [ radius>> sq ] [ sq ] [ norm-sq ] tri* - + ; inline

: -+ ( x y -- x-y x+y )
    [ - ] [ + ] 2bi ; inline

: sphere-t ( b d -- t )
    -+ dup 0.0 <
    [ 2drop 1/0. ] [ [ [ 0.0 > ] keep ] dip ? ] if ; inline

: sphere-b&v ( sphere ray -- b v )
    [ sphere-v ] [ nip ] 2bi
    [ sphere-b ] [ drop ] 2bi ; inline

: ray-sphere ( sphere ray -- t )
    [ drop ] [ sphere-b&v ] 2bi
    [ drop ] [ sphere-d ] 3bi
    dup 0.0 < [ 3drop 1/0. ] [ sqrt sphere-t nip ] if ; inline

: if-ray-sphere ( hit ray sphere quot -- hit )
    ! quot: hit ray sphere l -- hit
    [
        [ ] [ swap ray-sphere nip ] [ 2drop lambda>> ] 3tri
        [ drop ] [ < ] 2bi
    ] dip [ 3drop ] if ; inline

: sphere-n ( ray sphere l -- n )
    [ [ orig>> ] [ dir>> ] bi ] [ center>> ] [ ] tri*
    swap [ v*n ] dip v- v+ ; inline

M: sphere intersect-scene ( hit ray sphere -- hit )
    [ [ sphere-n normalize ] keep <hit> nip ] if-ray-sphere ;

HINTS: M\ sphere intersect-scene { hit ray sphere } ;

TUPLE: group < sphere { objs array read-only } ;

: <group> ( objs bound -- group )
    [ center>> ] [ radius>> ] bi rot group boa ; inline

: make-group ( bound quot -- )
    swap [ { } make ] dip <group> ; inline

M: group intersect-scene ( hit ray group -- hit )
    [ drop objs>> [ intersect-scene ] with each ] if-ray-sphere ;

HINTS: M\ group intersect-scene { hit ray group } ;

CONSTANT: initial-hit T{ hit f double-array{ 0.0 0.0 0.0 } 1/0. }

: initial-intersect ( ray scene -- hit )
    [ initial-hit ] 2dip intersect-scene ; inline

: ray-o ( ray hit -- o )
    [ [ orig>> ] [ normal>> delta v*n ] bi* ]
    [ [ dir>> ] [ lambda>> ] bi* v*n ]
    2bi v+ v+ ; inline

: sray-intersect ( ray scene hit -- ray )
    swap [ ray-o light vneg <ray> ] dip initial-intersect ; inline

: ray-g ( hit -- g ) normal>> light vdot ; inline

: cast-ray ( ray scene -- g )
    2dup initial-intersect dup lambda>> 1/0. = [
        3drop 0.0
    ] [
        [ sray-intersect lambda>> 1/0. = ] 1guard
        [ ray-g neg ] [ drop 0.0 ] if
    ] if ; inline

: create-center ( c r d -- c2 )
    [ 3.0 12.0 sqrt / * ] dip n*v v+ ; inline

DEFER: create

: create-step ( level c r d -- scene )
    over [ create-center ] dip 2.0 / [ 1 - ] 2dip create ;

: create-offsets ( quot -- )
    {
        double-array{ -1.0 1.0 -1.0 }
        double-array{ 1.0 1.0 -1.0 }
        double-array{ -1.0 1.0 1.0 }
        double-array{ 1.0 1.0 1.0 }
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
    [ oversampling /f ] bi@ 0.0 double-array{ } 3sequence ;

: ss-grid ( -- ss-grid )
    oversampling <iota> [ oversampling <iota> [ ss-point ] with map ] map ;

: ray-grid ( point ss-grid -- ray-grid )
    [
        [ v+ normalize double-array{ 0.0 0.0 -4.0 } swap <ray> ] with map
    ] with map ;

: ray-pixel ( scene point -- n )
    ss-grid ray-grid [ 0.0 ] 2dip
    [ [ swap cast-ray + ] with each ] with each ;

: pixel-grid ( -- grid )
    size <iota> reverse [
        size <iota> [
            [ size 0.5 * - ] bi@ swap size
            double-array{ } 3sequence
        ] with map
    ] map ;

: pgm-header ( w h -- )
    "P5\n" % swap # " " % # "\n255\n" % ;

: pgm-pixel ( n -- ) 255 * 0.5 + >fixnum , ;

: ray-trace ( scene -- pixels )
    pixel-grid [ [ ray-pixel ] with map ] with map ;

: run-raytracer ( -- string )
    levels double-array{ 0.0 -1.0 0.0 } 1.0 create ray-trace [
        size size pgm-header
        [ [ oversampling sq / pgm-pixel ] each ] each
    ] B{ } make ;

: raytracer-benchmark ( -- )
    run-raytracer "raytracer.pnm" temp-file binary set-file-contents ;

MAIN: raytracer-benchmark
