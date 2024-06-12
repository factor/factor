! Factor port of the raytracer benchmark from
! http://www.ffconsultancy.com/languages/ray_tracer/index.html

USING: arrays accessors generalizations io.files io.files.temp
io.encodings.binary kernel math math.constants math.functions
math.vectors math.vectors.simd.cords math.parser make sequences
words combinators ;
IN: benchmark.raytracer-simd

<< SYNTAX: no-compile last-word t "no-compile" set-word-prop ; >>

! parameters

! Normalized { -1 -3 2 }.
CONSTANT: light
    double-4{
        -0.2672612419124244
        -0.8017837257372732
        0.5345224838248488
        0.0
    }

CONSTANT: oversampling 4

CONSTANT: levels 3

CONSTANT: size 200

: delta ( -- n ) epsilon sqrt ; inline no-compile

TUPLE: ray { orig double-4 read-only } { dir double-4 read-only } ;

C: <ray> ray

TUPLE: hit { normal double-4 read-only } { lambda float read-only } ;

C: <hit> hit

TUPLE: sphere { center double-4 read-only } { radius float read-only } ;

C: <sphere> sphere

: sphere-v ( sphere ray -- v ) [ center>> ] [ orig>> ] bi* v- ; inline no-compile

: sphere-b ( v ray -- b ) dir>> vdot ; inline no-compile

: sphere-d ( sphere b v -- d ) [ radius>> sq ] [ sq ] [ norm-sq ] tri* - + ; inline no-compile

: -+ ( x y -- x-y x+y ) [ - ] [ + ] 2bi ; inline no-compile

: sphere-t ( b d -- t )
    -+ dup 0.0 <
    [ 2drop 1/0. ] [ [ [ 0.0 > ] keep ] dip ? ] if ; inline no-compile

: sphere-b&v ( sphere ray -- b v )
    [ sphere-v ] [ nip ] 2bi
    [ sphere-b ] [ drop ] 2bi ; inline no-compile

: ray-sphere ( sphere ray -- t )
    [ drop ] [ sphere-b&v ] 2bi
    [ drop ] [ sphere-d ] 3bi
    dup 0.0 < [ 3drop 1/0. ] [ sqrt sphere-t nip ] if ; inline no-compile

: if-ray-sphere ( hit ray sphere quot: ( hit ray sphere l -- hit ) -- hit )
    [
        [ ] [ swap ray-sphere nip ] [ 2drop lambda>> ] 3tri
        [ drop ] [ < ] 2bi
    ] dip [ 3drop ] if ; inline no-compile

: sphere-n ( ray sphere l -- n )
    [ [ orig>> ] [ dir>> ] bi ] [ center>> ] [ ] tri*
    swap [ v*n ] dip v- v+ ; inline no-compile

TUPLE: group < sphere { objs array read-only } ;

: <group> ( objs bound -- group )
    swap [ [ center>> ] [ radius>> ] bi ] dip group boa ; inline no-compile

: make-group ( bound quot -- )
    swap [ { } make ] dip <group> ; inline no-compile

: intersect-scene ( hit ray scene -- hit )
    {
        { [ dup group? ] [ [ drop objs>> [ intersect-scene ] with each ] if-ray-sphere ] }
        { [ dup sphere? ] [ [ [ sphere-n normalize ] keep <hit> nip ] if-ray-sphere ] }
    } cond ; inline recursive no-compile

CONSTANT: initial-hit T{ hit f double-4{ 0.0 0.0 0.0 0.0 } 1/0. }

: initial-intersect ( ray scene -- hit )
    [ initial-hit ] 2dip intersect-scene ; inline no-compile

: ray-o ( ray hit -- o )
    [ [ orig>> ] [ normal>> delta v*n ] bi* ]
    [ [ dir>> ] [ lambda>> ] bi* v*n ]
    2bi v+ v+ ; inline no-compile

: sray-intersect ( ray scene hit -- ray )
    swap [ ray-o light vneg <ray> ] dip initial-intersect ; inline no-compile

: ray-g ( hit -- g ) normal>> light vdot ; inline no-compile

: cast-ray ( ray scene -- g )
    2dup initial-intersect dup lambda>> 1/0. = [
        3drop 0.0
    ] [
        [ sray-intersect lambda>> 1/0. = ] 1guard
        [ ray-g neg ] [ drop 0.0 ] if
    ] if ; inline no-compile

: create-center ( c r d -- c2 )
    [ 3.0 12.0 sqrt / * ] dip n*v v+ ; inline no-compile

DEFER: create

: create-step ( level c r d -- scene )
    over [ create-center ] dip 2.0 / [ 1 - ] 2dip create ;

CONSTANT: create-offsets
    {
        double-4{ -1.0 1.0 -1.0 0.0 }
        double-4{ 1.0 1.0 -1.0 0.0 }
        double-4{ -1.0 1.0 1.0 0.0 }
        double-4{ 1.0 1.0 1.0 0.0 }
    }

: create-bound ( c r -- sphere ) 3.0 * <sphere> ;

: create-group ( level c r -- scene )
    2dup create-bound [
        2dup <sphere> ,
        create-offsets [ create-step , ] 3 nwith each
    ] make-group ;

: create ( level c r -- scene )
    pick 1 = [ <sphere> nip ] [ create-group ] if ;

: ss-point ( dx dy -- point )
    [ oversampling /f ] bi@ 0.0 0.0 double-4-boa ; inline no-compile

: ray-pixel ( scene point -- ray-grid )
    [ 0.0 ] 2dip
    oversampling <iota> [
        oversampling <iota> [
            ss-point v+ normalize
            double-4{ 0.0 0.0 -4.0 0.0 } swap <ray>
            swap cast-ray +
        ] 3 nwith each
    ] 2with each ; inline no-compile

: ray-trace ( scene -- grid )
    size <iota> <reversed> [
        size <iota> [
            [ size 0.5 * - ] bi@ swap size
            0.0 double-4-boa ray-pixel
        ] 2with map
    ] with map ;

: pgm-header ( w h -- )
    "P5\n" % swap # " " % # "\n255\n" % ;

: pgm-pixel ( n -- ) 255 * 0.5 + >fixnum , ;

: run-raytracer-simd ( -- string )
    levels double-4{ 0.0 -1.0 0.0 0.0 } 1.0 create ray-trace [
        size size pgm-header
        [ [ oversampling sq / pgm-pixel ] each ] each
    ] B{ } make ;

: raytracer-simd-benchmark ( -- )
    run-raytracer-simd "raytracer.pnm" temp-file binary set-file-contents ;

MAIN: raytracer-simd-benchmark
