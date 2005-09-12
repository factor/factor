! Factor port of the raytracer benchmark from
! http://www.ffconsultancy.com/free/ray_tracer/languages.html

USING: arrays generic io kernel lists math namespaces sequences ;
IN: ray

! parameters
: light
    #! Normalized { -1 -3 2 }.
    @{
        -0.2672612419124244
        -0.8017837257372732
        0.5345224838248488
    }@ ; inline

: oversampling 4 ; inline

: levels 3 ; inline

: size 200 ; inline

! kludge
: INF inf swons ; parsing

: delta 1.4901161193847656E-8 ; inline

TUPLE: ray orig dir ;

TUPLE: hit normal lambda ;

GENERIC: intersect-scene ( hit ray scene -- hit )

TUPLE: sphere center radius ;

: sphere-v ( sphere ray -- v )
    swap sphere-center swap ray-orig v- ;

: sphere-b ( ray v -- b ) swap ray-dir v. ;

: sphere-disc ( sphere v b -- d )
    sq swap norm-sq - swap sphere-radius sq + ;

: -+ ( x y -- x-y x+y ) [ - ] 2keep + ;

: sphere-b/d ( b d -- t )
    -+ dup 0.0 < [ 2drop inf ] [ >r [ 0.0 > ] keep r> ? ] ifte ;

: ray-sphere ( sphere ray -- t )
    2dup sphere-v tuck sphere-b [ sphere-disc ] keep
    over 0.0 < [ 2drop inf ] [ swap sqrt sphere-b/d ] ifte ;

: sphere-n ( ray sphere l -- n )
    pick ray-dir n*v swap sphere-center v- swap ray-orig v+ ;

: if-ray-sphere ( hit ray sphere quot -- hit )
    #! quot: hit ray sphere l -- hit
    >r pick hit-lambda >r 2dup swap ray-sphere dup r> >=
    [ 3drop ] r> ifte ; inline

M: sphere intersect-scene ( hit ray sphere -- hit )
    [ [ sphere-n normalize ] keep <hit> nip ] if-ray-sphere ;

TUPLE: group objs ;

C: group ( objs bound -- group )
    [ set-delegate ] keep [ set-group-objs ] keep ;

: make-group ( bound quot -- )
    swap >r { } make r> <group> ; inline

M: group intersect-scene ( hit ray group -- hit )
    [
        drop
        group-objs [ >r tuck r> intersect-scene swap ] each
        drop
    ] if-ray-sphere ;

: initial-hit << hit f @{ 0.0 0.0 0.0 }@ INF >> ;

: initial-intersect ( ray scene -- hit )
    initial-hit -rot intersect-scene ;

: ray-o ( ray hit -- o )
    over ray-dir over hit-lambda v*n
    swap hit-normal delta v*n v+
    swap ray-orig v+ ;

: sray-intersect ( ray scene hit -- ray )
    swap >r ray-o light vneg <ray> r> initial-intersect ;

: ray-g ( hit -- g ) hit-normal light v. ;

: cast-ray ( ray scene -- g )
    2dup initial-intersect dup hit-lambda inf = [
        3drop 0.0
    ] [
        dup ray-g >r sray-intersect hit-lambda inf =
        [ r> neg ] [ r> drop 0.0 ] ifte
    ] ifte ;

: create-center ( c r d -- c2 ) >r 3.0 12.0 sqrt / * r> n*v v+ ;

DEFER: create ( level c r -- scene )

: create-step ( level c r d -- scene )
    over >r create-center r> 2.0 / >r >r 1 - r> r> create ;

: create-offsets ( quot -- )
    @{
        @{ -1.0 1.0 -1.0 }@
        @{ 1.0 1.0 -1.0 }@
        @{ -1.0 1.0 1.0 }@
        @{ 1.0 1.0 1.0 }@
    }@ swap each ; inline

: create-bound ( c r -- sphere ) 3.0 * <sphere> ;

: create-group ( level c r -- scene )
    2dup create-bound [
        2dup <sphere> ,
        [ >r 3dup r> create-step , ] create-offsets 3drop
    ] make-group ;

: create ( level c r -- scene )
    pick 1 = [ <sphere> nip ] [ create-group ] ifte ;

: ss-point ( dx dy -- point )
    >r oversampling /f r> oversampling /f 0.0 3array ;

: ss-grid ( -- ss-grid )
    oversampling [ oversampling [ ss-point ] map-with ] map ;

: ray-grid ( point ss-grid -- ray-grid )
    [
        [ v+ normalize @{ 0.0 0.0 -4.0 }@ swap <ray> ] map-with
    ] map-with ;

: ray-pixel ( scene point -- n )
    ss-grid ray-grid 0.0 -rot
    [ [ swap cast-ray + ] each-with ] each-with ;

: pixel-grid ( -- grid )
    size reverse [
        size [
            size 0.5 * - swap size 0.5 * - size >float 3array
        ] map-with
    ] map ;

: pixel-grid ( -- grid )
    size reverse [
        size [
            size 0.5 * - swap size 0.5 * - size >float 3array
        ] map-with
    ] map ;

: pnm-header ( w h -- )
    "P5\n" % swap # " " % # "\n255\n" % ;

: pnm-pixel ( n -- ) 255 * 0.5 + >fixnum , ;

: ray-trace ( scene -- pixels )
    pixel-grid [ [ ray-pixel ] map-with ] map-with ;

: run ( -- string )
    levels @{ 0.0 -1.0 0.0 }@ 1.0 create ray-trace [
        size size pnm-header
        [ [ oversampling sq / pnm-pixel ] each ] each
    ] "" make ;

: run>file ( file -- ) <file-writer> [ run write ] with-stream ;
